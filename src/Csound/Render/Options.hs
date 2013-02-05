module Csound.Render.Options(
    CsdOptions(..), mixing, mixingBy,
    renderInstr0, renderFlags, MidiAssign(..), CtrlId
) where

import Data.List(transpose)
import Data.Default
import Text.PrettyPrint

import Csound.Exp.Wrapper(Channel, Sig, SE, Out)
import Csound.Render.Sco
import Csound.Render.Pretty

type CtrlId = Int

-- | Sums signals for every channel.
mixing :: [[Sig]] -> Out
mixing = return . fmap sum . transpose

-- | Sums signals for every channel and the processes the output with the given function.
mixingBy :: ([Sig] -> Out) -> ([[Sig]] -> Out)
mixingBy f = (f =<<) . mixing 

-- | Csound options. The default value is
--
-- > instance Default CsdOptions where
-- >     def = CsdOptions 
-- >             { csdFlags = ""
-- >             , csdRate  = 44100
-- >             , csdBlockSize = 64
-- >             , csdSeed = Nothing
-- >             , csdInitc7 = []
-- >             , csdEffect = mixing
-- >             , csdKrate  = ["linseg", "expseg", "linsegr", "expsegr"] }

data CsdOptions = CsdOptions 
    { csdFlags      :: String       
    , csdRate       :: Int          
    , csdBlockSize  :: Int          
    , csdSeed       :: Maybe Int    
    , csdInitc7     :: [(Channel, CtrlId, Double)]
    , csdEffect     :: [[Sig]] -> SE [Sig]
    , csdKrate      :: [String]
    }

instance Default CsdOptions where
    def = CsdOptions 
            { csdFlags = ""
            , csdRate  = 44100
            , csdBlockSize = 64
            , csdSeed = Nothing
            , csdInitc7 = []
            , csdEffect = mixing
            , csdKrate  = ["linseg", "expseg", "linsegr", "expsegr"] }

renderFlags = text . csdFlags

type Nchnls = Int

data MidiAssign = MidiAssign 
    { midiAssignType    :: MidiType
    , midiAssignChannel :: Channel
    , midiAssignInstr   :: Int }

type InstrId = Int

renderInstr0 :: Nchnls -> [MidiAssign] -> CsdOptions -> Doc
renderInstr0 nchnls massignTable opt = vcat [
    stmt "sr"    $ csdRate opt,
    stmt "ksmps" $ csdBlockSize opt,
    stmt "nchnls" nchnls,   
    maybe empty seed $ csdSeed opt,    
    vcat $ map initc7 $ csdInitc7 opt,    
    vcat $ fmap renderMidiAssign massignTable]
    where stmt a b = assignTo (text a) (int b)
          seed n = ppOpc "seed" [int n]
          initc7 (chn, ctl, val) = ppOpc "initc7" [int chn, int ctl, double val]
            
  
renderMidiAssign :: MidiAssign -> Doc
renderMidiAssign a = ppOpc opcode $ [int $ midiAssignChannel a, int $ midiAssignInstr a] ++ auxParams
    where opcode = case midiAssignType a of
              Massign     -> "massign"
              Pgmassign _ -> "pgmassign"
          auxParams = case midiAssignType a of 
              Pgmassign (Just n) -> [int n]
              _ -> []  



