# Quakes (v0.0.1)

## Install

```bash
$ git clone git@github.com:aliaksandrb/quakes.git
$ cd quakes
$ bin/quakes --help
```

## Usage

```bash
Usage: bin/quakes [options...] <command>

Commands:
  --top<N>    Print a list of the top <N> US states by number of earthquakes
              example: $ bin/quakes --top5
  --<state>   Print a list of the top 25 strongest earthquakes in <state>
              example: $ bin/quakes --california
  --help      Print this message
              example: $ bin/quakes --help
  --version   Print program version
              example: $ bin/quakes --version

Options:
              By default all results are sorted as 'highest to lowest' (desc) and
              remote dataset is used for analysis.
              You can change that behaviour by the following switches:

  --asc       Changes order of results to 'lowest to highest' (asc)
              example: $ bin/quakes --asc --top5
  --f <path>  Use local dataset source available at <path> for analysis
              example: $ bin/quakes --f data/all_month.geojson --top5
  --net <url> DEFAULT: Download and analyze the most recent dataset from <url>
              example: $ bin/quakes --net https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_month.geojson --top5
```

## Tests

```
$ bundle install
$ rake
```

:shipit:
