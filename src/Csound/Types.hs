-- | The Csound types.
--
-- There are several primitive types:
--
-- * @Sig@ - signals
--
-- * @D@ - numbers
--
-- * @Str@ - strings
--
-- * @Tab@ - 1-dimensional arrays
--
-- * @Spec@ and @Wspec@ - sound spectrums
--
--  A signal is a stream of numbers. Signals carry sound or time varied 
--  control values. Numbers are constants. 1-dimensional arrays contain some useful
--  data which is calculated at the initial run of the program.
--
-- There is only one compound type. It's a tuple of Csound values. The empty tuple
-- is signified with special type called @Unit@. 
--
module Csound.Types(
    -- * Primitive types    
    Sig, D, Tab, Str, Spec, Wspec,    
    BoolSig, BoolD, Val(..), SigOrD,

    Sig2, Sig3, Sig4, Sig5, Sig6, Sig8,
    -- ** Constructors
    double, int, text, 
    
    -- ** Constants
    idur, getSampleRate, getControlRate, getBlockSize,

    -- ** Converters
    ar, kr, ir, sig,

    -- ** Init values
    withInits, withDs, withSigs, withTabs, 
    withD, withSig, withTab, withSeed,

    -- ** Numeric functions
    quot', rem', div', mod', ceil', floor', round', int', frac',        
   
    -- ** Logic functions
    boolSig, when1, whens, whenD1, whenDs, whileDo, untilDo, whileDoD, untilDoD,
    equalsTo, notEqualsTo, lessThan, greaterThan, lessThanEquals, greaterThanEquals,

    -- ** Aliases 
    -- | Handy for functions that return tuples to specify the utput type
    --
    -- > (aleft, aright) = ar2 $ diskin2 "file.wav" 1
    -- 
    -- or
    --
    -- > asig = ar1 $ diskin2 "file.wav" 1    
    ar1, ar2, ar4, ar6, ar8,

    -- * Tuples
    Tuple(..), makeTupleMethods, Unit, unit, atTuple,
    -- *** Logic functions
    ifTuple, guardedTuple, caseTuple, 
    
    -- * Instruments    

    -- | An instrument is a function that takes a tpule of csound values as an argument
    -- and returns a tuple of signals as an output. The type of the instrument is:
    --
    -- > (Arg a, Out b) => a -> b

    -- ** Arguments
    Arg, atArg,
    -- *** Logic functions
    ifArg, guardedArg, caseArg, 

    -- ** Outputs
    Sigs
) where

import Data.Boolean
import Csound.Typed.Types

-- | Gets an init-rate value from the list by index.
atArg :: (Tuple a, Arg a) => [a] -> D -> a
atArg as ind = guardedArg (zip (fmap (\x -> int x ==* ind) [0 .. ]) as) (head as)

-- | Gets an control/audio-rate value from the list by index.
atTuple :: (Tuple a) => [a] -> Sig -> a
atTuple as ind = guardedTuple (zip (fmap (\x -> sig (int x) ==* ind) [0 .. ]) as) (head as)

