-- | Primitive GUI elements.
--
-- There is a convention that constructors take only parameters that 
-- specify the logic of the widget. The view is set for GUI-elements with 
-- other functions.
module Csound.Control.Gui.Widget (
    -- * Common properties 
    ValDiap(..), ValStep, ValScaleType(..), ValSpan(..),
    linSpan, expSpan, uspan, bspan, uspanExp,
    -- * Valuators
    count, countSig, joy, 
    knob, KnobType(..), setKnobType,
    roller, 
    slider, sliderBank, SliderType(..), setSliderType,
    numeric, TextType(..), setTextType,

    -- * Other widgets
    box, BoxType(..), setBoxType,
    button, ButtonType(..), setButtonType, 
    toggle, butBank, buttonSig, toggleSig, butBankSig,
    butBank1, butBankSig1, 
    radioButton, matrixButton, funnyRadio, funnyMatrix,
    value, meter,
    -- * Transformers
    setTitle
) where

import Data.List(transpose)
import Data.Boolean

import Csound.Typed.Gui
import Csound.Typed.Types
import Csound.Control.Evt(listAt)

--------------------------------------------------------------------
-- aux widgets

readMatrix :: Int -> Int -> [a] -> [a]
readMatrix xn yn as = transp $ take (xn * yn) $ as ++ repeat (head as)
    where 
        transp xs = concat $ transpose $ parts yn xn xs
        parts x y qs 
            | x == 0    = []
            | otherwise = a : parts (x - 1) y b
            where (a, b) = splitAt y qs

-- | A radio button. It takes a list of values with labels.
radioButton :: Arg a => String -> [(String, a)] -> Source (Evt a)
radioButton title as = source $ do
    (g, ind) <- butBank1 "" 1 (length as) 
    gnames   <- mapM box names
    let val = listAt vals ind    
    gui <- setTitle title $ padding 0 $ hor [sca 0.15 g, ver gnames]
    return (gui, val)
    where (names, vals) = unzip as

-- | A matrix of values.
matrixButton :: Arg a => String -> Int -> Int -> [a] -> Source (Evt a)
matrixButton name xn yn vals = source $ do
    (gui, ind) <- butBank1 name xn yn 
    let val = listAt allVals ind
    return (gui, val)
    where allVals = readMatrix xn yn vals

-- | Radio button that returns functions. Useful for picking a waveform or type of filter.
funnyRadio :: Tuple b => String -> [(String, a -> b)] -> Source (a -> b)
funnyRadio name as = source $ do
    (gui, ind) <- radioButton name $ zip names (fmap int [0 ..])
    contInd <- stepper 0 $ fmap sig ind
    let instr x = guardedTuple (
                zipWith (\n f -> (contInd ==* (sig $ int n), f x)) [0 ..] funs
            ) (head funs x)
    return (gui, instr)
    where (names, funs) = unzip as

-- | Matrix of functional values.
funnyMatrix :: Tuple b => String -> Int -> Int -> [(a -> b)] -> Source (a -> b)
funnyMatrix name xn yn funs = source $ do
    (gui, ind) <- butBank1 name xn yn
    contInd <- stepper 0 $ fmap sig ind
    let instr x = guardedTuple (
                zipWith (\n f -> (contInd ==* (sig $ int n), f x)) [0 ..] allFuns
            ) (head allFuns x)
    return (gui, instr)
    where allFuns = readMatrix xn yn funs

