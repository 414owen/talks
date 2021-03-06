{-# LANGUAGE ConstraintKinds #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Clock.Hands (hands) where

import Control.Monad
import Control.Monad.Fix
import Control.Monad.IO.Class
import Data.Text (Text)
import Reflex.Dom.Core

import Clock.Time (seconds, minutes, hours)
import Clock.Util

type ClientSideM t m =
  ( DomBuilder t m
  , MonadIO m
  , MonadIO (Performable m)
  , PerformEvent t m
  , MonadHold t m
  , TriggerEvent t m
  , PostBuild t m
  , MonadFix m
  )

svgElDynAttr :: (DomBuilder t m, PostBuild t m) => Text -> Dynamic t Ats -> m a -> m a
svgElDynAttr = elDynAttrNS (Just "http://www.w3.org/2000/svg")

hand :: ClientSideM t m => Dynamic t Float -> Text -> Int -> m ()
hand rotation width len = svgElDynAttr "line" atts $ pure ()
  where
    atts = ffor rotation $ \rot ->
         "stroke-width" =: width
      <> "stroke" =: "black"
      <> rotate rot
      <> "stroke" =: "black"
      <> "x1" =: "50"
      <> "x2" =: "50"
      <> "y1" =: "50"
      <> "y2" =: tshow (50 - len)

toRotation :: Functor f => Float -> f Float -> f Float
toRotation n = fmap ((/ n) . (* 360))

hands :: forall t m. (DomBuilder t m, Prerender t m) => m ()
hands = void $ prerender (pure ()) $ do
  s :: Dynamic t Float <- seconds
  hand (toRotation 60 s) "1" 50
  m <- minutes
  hand (toRotation 60 m) "2" 32
  h <- hours
  hand (toRotation 12 h) "3" 30
  pure ()
