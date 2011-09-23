# M2D: A 2D Library for Molehill

## What is M2D

M2D is a 2D sprite library using Molehill, the new GPU hardware accelerated API for flash.  M2D is intended for projects that primarily use bitmaps for rendering, giving up much of the lovely goodness that is the flash display list.

## Current Status

M2D is *not* under current development.  For GPU accelerated 2D support in flash, please consider using the starling framework at http://www.starling-framework.org/

## Why M2D?

M2D was built (is being built) for a few reasons:

1. as a starter point for the many great bitmap based flash libraries used by the flash game community today.  Libraries like Push Button Engine, Flixel, and many many more serve the community well, and the intention is not to displace them.  If anything, it's to help encourage them to integrate Molehill support into their own libraries.
2. as a library in its own right.  Depending on the interest, and contribution, it may grow into something full fledged and broadly useful, or it may remain a proving ground for technologies the other game libraries can adopt as they see fit.


## What does M2D consist of?

1. a set of optimized 2D sprite drawing routines.  Independent from the rest of the library, the GContext class is a wrapper around molehill that batches up 2D bitmap draws into as few draw calls as possible.
2. a retained mode 'world' infrastructure for doing display-list like 2D rendering on molehill.
3. a bare bones set of classes for managing symbols and sprite instances in the world.
4. a basic particle system for rendering large numbers of particles parametrically on the GPU.
5. various stubbed out sections for animation, time, etc.


## How optimized is M2D?
Sortof-ish?  It's better than the most brute force no-thought way you would use molehill to draw 2D sprites, but there's probably still lots of inneficiencies in there.  Probably an extra matrix calculation here and there that could be cached, that sort of thing. If you see problems, please feel free to submit improvements.

## how complete is M2D?
Not too complete.  It's complete enough to write tests, but at this point, not ready for prime time.  There's no way to dispose of sprites and symbols, for example.  There's no defense against loss of the GPU context.  Again, if there's interest, that stuff will come.  

## Can I help?
Sure!  Send an email, send a patch, roll up your sleeves and get coding.  Email me at m2d@quietlyscheming.com

