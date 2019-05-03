Attempt at writing an RPG map render code in 6502 assembler

## Build

```
make
```

builds the prg file and generates a d64 file

## Testing

```
make run
```

launches the built d64 in vice and autostarts the main program.

## Memory

Using vic bank 1 ($4000-$7fff)


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

I'm using sprite interleaving for the overlay. Every 16 rows I update sprite pointers
and alternate the screen ram loacation between two position.

```
>>> range(0,16*11,16)
[0, 16, 32, 48, 64, 80, 96, 112, 128, 144, 160]
```

The sprite pointer update in the incative screen buffer and swapping of the
inactive buffer into active mode takes about two raster lines. Due to the 16
line stride we can have all of those fall on good lines!


Every 21 lines a new sprite row starts.

```
>>> range(0,16*11,21)
[0, 21, 42, 63, 84, 105, 126, 147, 168]
```

The postion pointers must be set sometime while the previous row is being
displayed. So for the positions liste below the update could occur at the
following raster lines

```
160, 0, 32, 48, 80, 96, 112, 144, 160
```

These correspond to a subset of the interrupts, performing a position update
right after the screen buffer switch.
