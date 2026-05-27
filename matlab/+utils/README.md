# General Utilities

This package contains nested utilities for functions.

## Functions

:large_blue_circle: = Planned

:yellow_circle: = In Progress

:green_circle: = Implemented

| Function | Status | Purpose | Notes |
|---|---|---|---|
| 'ensure_column_exists' | :large_blue_circle: | Checks for column names in a table for error handling | Expects .sto or .mot file header structure, update as necessary |
| 'make_output_path' | :large_blue_circle: | Defines output paths on system | None |
| 'must_have_fields' | :large_blue_circle: | Checks for necessary fields of variables type 'struct' | OpenSim model structs do not create placeholder fields for nonexistent data |
| 'safe_struct_get' | :large_blue_circle: | Ensures model to struct conversion is handled safely | None |