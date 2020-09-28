# Memory layout

Start | End  | Use
------|------|--------
$00   |$FF   | Zeropage
$0340 |$03B8 | Viewport

Using vic bank 1 ($4000-$7fff)

      | Tiles C     |
      | Tiles H     |
      | Tiles S     |
$8000 |-------------|
      |             |
      | Sprites     |
      |             |
$6800 |-------------|
      | Screen 1    |
$6400 |-------------|
      | Screen 0    |
$6000 |-------------|
      |             |
      |             |
      |             |
      | Hires       |
      |             |
      |             |
      |             |
      |             |
$4000 |-------------|

## Sprite overlay

I'm using sprite interleaving for the overlay. Every 16 rows I update sprite
pointers and alternate the screen ram location between two position.

```
>>> range(0,16*11,16)
[0, 16, 32, 48, 64, 80, 96, 112, 128, 144, 160]
```

The sprite pointer update in the inactive screen buffer and swapping of the
inactive buffer into active mode takes about two raster lines. Due to the 16
line stride we can have all of those fall on good lines!


Every 21 lines a new sprite row starts.

```
>>> range(0,16*11,21)
[0, 21, 42, 63, 84, 105, 126, 147, 168]
```

The position pointers must be set sometime while the previous row is being
displayed. So for the positions listed below the update could occur at the
following raster lines

```
160, 0, 32, 48, 80, 96, 112, 144, 160
```

These correspond to a subset of the interrupts, performing a position update
right after the screen buffer switch.

## Tile data

Each tile takes 68 bytes of data, split in 3 sections
32 bytes for the sprite overlay start at $8000 (Tiles S) for all tiles.
This is followed by thh same amount of data - 32 bytes each - of HiRes data
(Tiles H) starting at $8???, and 4 bytes of color data for each tile (Tiles C)
starting at $8???
