use v6;
use nqp;

multi sub postcircumfix:<{|| }>(\SELF, @indices) is raw is export {
    my \target = IterationBuffer.new;
    MD-HASH-SLICE-ONE-POSITION(SELF, @indices, @indices.AT-POS(0), 0, target);
    nqp::p6bindattrinvres(nqp::create(List), List, '$!reified', target)
};

