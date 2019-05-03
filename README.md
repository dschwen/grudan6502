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
