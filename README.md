# Glob Match

![License: MIT][shield-license-mit]
[![CI][shield-ci]][workflow-ci]
[![Ubuntu][shield-platform-ubuntu]][job-runs-on]
[![macOS][shield-platform-macos]][job-runs-on]
[![Windows][shield-platform-windows]][job-runs-on]

A GitHub Action for matching `glob` patterns.

## Features

- Matches filenames and pathes using [glob patterns][glob-cheat-sheet]
  - ... in the live file system
  - ... from a user-supplied input
  - ... from an input pipe
- Fast execution
- Scales to large repositories
- Supports all platforms (Linux, macOS, Windows)
- Does not use external GitHub Actions dependencies

## Usage

### Match Files in the Life File System

```yaml
steps:
  - name: Glob Match
    id: glob
    uses: zyactions/glob@v1
    with:
      pattern: |
        **/[ac].txt
        !test/a.txt

  - name: Print Matches
    run: |
      echo "${{ steps.glob.outputs.matches }}"
```

### Match Input Values

```yaml
steps:
  - name: Glob Match
    id: glob
    uses: zyactions/glob@v1
    with:
      pattern: '**/[ac].txt'
      values: |-
        test/a.txt
        test/b.txt
        text/c.txt

  - name: Print Matches
    run: |
      echo "${{ steps.glob.outputs.matches }}"
```

The input values must be separated by line breaks.

### Match Input Values from Pipe

```yaml
steps:
  - name: Glob Match
    id: glob
    uses: zyactions/glob@v1
    with:
      pattern: '**/[ac].txt'
      pipe: 'git diff --name-only'

  - name: Print Matches
    run: |
      echo "${{ steps.glob.outputs.matches }}"
```

This is especially useful when a large number of items need to be matched without first storing them in an action output, environment variable, temporary file, or other temporary storage.

The input values returned by the pipe command must be separated by line breaks.

### Return a Pipe Command

```yaml
steps:
  - name: Glob Match
    id: glob
    uses: zyactions/glob@v1
    with:
      pattern: '**/[ac].txt'
      return-pipe: true

  - name: Print Matches
    shell: bash
    run: |
      ${{ steps.glob.outputs.pipe }} | while IFS= read -r x ; do echo $x ; done
```

The `return-pipe` option can also be combined with the `pipe` input to insert a glob filter step in the middle of a pipeline.

## Inputs

### `pattern`

One or more file, path, or placeholder patterns that describe which items to match.

Check out the [glob pattern cheat sheet][glob-cheat-sheet] for reference. Multi line patterns must be specified without quotes.

> **Note**
>
> When running on Windows, `/` and `\` are accepted as path separators. When running on UNIX systems, only `/` is accepted as the path separator. This as well applies to the input values.

### `values`

An optional list of values to be matched (separated by line breaks).

The action operates on the life file system if neither the `values`-, nor the `pipe`-input is set.

> **Note**
>
> This input must be used mutually exclusive with the `pipe` input.

### `pipe`

An optional pipe input from which the input values are to be read.

This must be set to a valid shell command line (bash) that can be used for piping. The command must output to `stdout` and separate the individual values by line breaks.

The action operates on the life file system if neither the `values`-, nor the `pipe`-input is set.

> **Warning**
>
> The command passed to this input will be evaluated and should not come from untrusted sources.

> **Note**
>
> This input must be used mutually exclusive with the `values` input.

### `quote`

Enable this option to separate matching elements with spaces instead of line breaks and to enable enable shell quoting.

Example output for `test/a.txt`, `test/b.txt` and `test/'.txt`:

```bash
'test/a.txt' 'test/b.txt' 'test/'\''.txt'
```

### `sort`

Enable this option to sort the output elements. Not recommended for large result sets.

### `return-pipe`

Enable this option to return a shell (bash) command in the `pipe` output that can be used for piping.

The output command must be `eval`ed to return the results. It can also be passed to other actions that support a `pipe` input.

> **Note**
>
> The `matches` output will not be populated if this option is enabled.

## Outputs

### `matches`

A list of all matching elements, delimited by newlines or spaces (if the `quote` option is used).

> **Note**
>
> This output is only available if the `return-pipe` option is not enabled.

### `pipe`

A shell (bash) command which can be used for piping.
      
> **Note**
>
> This output is only available if the `return-pipe` option is enabled.

## Dependencies

This action does not use external GitHub Actions dependencies.

Internal depenencies:

- [wcmatch][wcmatch] (bundled)

## Versioning

Versions follow the [semantic versioning scheme][semver].

## License

Glob Match Action is licensed under the MIT license.

[glob-cheat-sheet]: https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#filter-pattern-cheat-sheet
[job-runs-on]: https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions#jobsjob_idruns-on
[semver]: https://semver.org
[shield-license-mit]: https://img.shields.io/badge/License-MIT-blue.svg
[shield-ci]: https://github.com/zyactions/glob/actions/workflows/ci.yml/badge.svg
[shield-platform-ubuntu]: https://img.shields.io/badge/Ubuntu-E95420?logo=ubuntu\&logoColor=white
[shield-platform-macos]: https://img.shields.io/badge/macOS-53C633?logo=apple\&logoColor=white
[shield-platform-windows]: https://img.shields.io/badge/Windows-0078D6?logo=windows\&logoColor=white
[wcmatch]: https://github.com/facelessuser/wcmatch
[workflow-ci]: https://github.com/zyactions/glob/actions/workflows/ci.yml
