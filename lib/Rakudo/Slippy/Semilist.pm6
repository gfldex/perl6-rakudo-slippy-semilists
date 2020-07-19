use v6.c;
use nqp;

multi sub postcircumfix:<{|| }>(\SELF, \indices) is raw is export {
    sub MD-HASH-SLICE-ONE-POSITION(\SELF, \indices, \idx, int $dim, \target) {
        my int $next-dim = $dim + 1;
        if $next-dim < indices.elems {
            if nqp::istype(idx, Iterable) && !nqp::iscont(idx) {
                MD-HASH-SLICE-ONE-POSITION(SELF, indices, $_, $dim, target)
                for idx;
            }
            elsif nqp::istype(idx, Str) {
                MD-HASH-SLICE-ONE-POSITION(SELF.AT-KEY(idx),
                indices, indices.AT-POS($next-dim), $next-dim, target)
            }
            elsif nqp::istype(idx, Whatever) {
                MD-HASH-SLICE-ONE-POSITION(SELF.AT-KEY($_),
                indices, indices.AT-POS($next-dim), $next-dim, target)
                for SELF.keys;
            }
            else  {
                MD-HASH-SLICE-ONE-POSITION(SELF.AT-KEY(idx),
                indices, indices.AT-POS($next-dim), $next-dim, target)
            }
        }
        else {
            if nqp::istype(idx, Iterable) && !nqp::iscont(idx) {
                MD-HASH-SLICE-ONE-POSITION(SELF, indices, $_, $dim, target)
                for idx;
            }
            elsif nqp::istype(idx, Str) {
                nqp::push(target, SELF.AT-KEY(idx))
            }
            elsif nqp::istype(idx, Whatever) {
                for SELF.keys {
                    nqp::push(target, SELF.AT-KEY($_))
                }
            }
            else {
                nqp::push(target, SELF.AT-KEY(idx))
            }
        }
    }

    my \target = IterationBuffer.new;
    MD-HASH-SLICE-ONE-POSITION(SELF, indices, indices.AT-POS(0), 0, target);
    nqp::p6bindattrinvres(nqp::create(List), List, '$!reified', target)
}

multi sub postcircumfix:<{|| }>(\SELF, \indices, :$exists!) is raw is export {
    sub recurse-at-key(\SELF, \indices, \counter){
        my $idx = indices[counter];
        (counter < indices.elems) 
            ?? SELF.EXISTS-KEY($idx) && recurse-at-key(SELF{$idx}, indices, counter + 1) 
            !! True
    }

    recurse-at-key(SELF, indices, 0)
}

multi sub postcircumfix:<{; }>(\SELF, @indices, :$exists!) is raw is export {
    sub recurse-at-key(\SELF, \indices, \counter){
        my $idx = indices[counter];
        (counter < indices.elems) 
            ?? SELF.EXISTS-KEY($idx) && recurse-at-key(SELF{$idx}, indices, counter + 1) 
            !! True
    }

    recurse-at-key(SELF, @indices, 0)
}

