# Lab 03: Scripting

The goal of this activity is to get you comfortable with writing scripts in Python and bash. You will practice working with environment variables, making API requests, and using command-line arguments. Follow the steps below to create scripts that demonstrate these fundamental scripting concepts.

> **Note:** Review and adhere to [coding best practices](https://github.com/ksiller/DS2022/blob/main/best-practices.md) where applicable when developing your scripts.

## Setup

For the Python script in this lab, you will need Python 3 and the [uv](https://docs.astral.sh/uv/) package manager installed on your computer.

**Confirm that both are installed:**  
Open a terminal window and run these commands (if you are on a Windows system, make sure you are in a WSL bash terminal, not PowerShell).

```bash
which python3
python3 -V
```

That path should be something like `/usr/bin/python3`, and the version should be 3.11 or newer.

```bash
uv --version
```

If this command fails with an error, install uv by following the official instructions: [Installing uv](https://docs.astral.sh/uv/getting-started/installation/). On macOS/Linux you can use:

```bash
curl -LsSf https://astral.sh/uv/install.sh -o uv-installer.sh
sh uv-installer.sh
```

## Script 1: Use Python to fetch remote data

**The Case:** A team wants a simple view of recent GitHub activity for a developer account. Checking profiles by hand does not scale, so they want a small script that calls the GitHub API and prints recent events.

**Your Task:** Set up a Python project with `uv`, install the `requests` library, and write a script that fetches and displays recent GitHub activity for a user stored in an environment variable.

### Setup: uv project and requests

1. Log in to GitHub and fork this repository: [https://github.com/ksiller/lab-03-scripting](https://github.com/ksiller/lab-03-scripting).

2. Clone your fork locally, then change into the `lab-03-scripting` directory.

3. Confirm that you are in the repository's top-level directory (`lab-03-scripting`), then initialize a `uv` project:

```bash
uv init --name ghevents --description "Parse GH events"
```

This command creates the project files `uv` needs, typically `pyproject.toml`, a hidden `.python-version` file, and a `src/ghevents/` package directory.

- `pyproject.toml`: Open this file in your editor (or run `cat pyproject.toml` in your terminal). Notice the `name` and `description` fields; their values match the command-line options you passed to `uv init`. Also notice that the `dependencies` field is defined as an empty list `[]`.
- `.python-version`: This is likely the Python version `uv` found when it ran `uv init`. You can change the version if you prefer a different one.
- `src/ghevents/`: This is where your Python script belongs. Initially it contains `__init__.py`, which makes your project importable by other Python scripts or projects.

Add the `requests` package:

```bash
uv add requests
```

The following will happen:

- `pyproject.toml`: The `dependencies` field now contains an entry for `requests`. By default it is pinned to the latest version available when the `uv add` command was executed.
- `uv.lock`: A declarative description of the exact Python package versions added to your project. Scroll down to `requests` and note that it has a specific version. This makes your environment exactly reproducible on other systems. Do not edit it manually.
- `.venv`: A new hidden directory with `lib` and `bin` subfolders and a few additional files that help manage an isolated environment for your Python project and its dependency packages. Check the `lib` folder; this is where the `requests` package (along with its own dependencies) was installed.

Create a `.gitignore` file in the repository's top-level directory so Git does not track the virtual environment. You can run:

```bash
echo ".venv/" >> .gitignore
```

Or create `.gitignore` in your editor and add the single line `.venv/` to that file.

### Build the script

**1.** Create a new script called `github-events.py` in `src/ghevents/` (the package directory created by `uv init`), and open it in an editor.

**2.** Put your Python 3 path in a shebang line. Use the more flexible `/usr/bin/env python3` form (see lecture slides). Because dependencies live in the `uv` environment, run the finished script with `uv run` (shown in step 8) so the `requests` package can be found by the Python interpreter.

**3.** For this script you will need to set an environment variable in your shell. Edit your `~/.bashrc` file (or `~/.zshrc`) and export a new variable named `GITHUB_USER`. Give it the value of your own GitHub username.

```bash
export GITHUB_USER="ksiller"  # replace with your own GitHub username
```

After you add this line, run `source ~/.bashrc` (or `source ~/.zshrc`) to load the new value into your environment.

**4.** Back to your Python script. Structure `github-events.py` as follows.

The GitHub events API address has this form:

```text
https://api.github.com/users/USERNAME/events
```

First add the imports, then define `GHUSER` and `url` as module-level (global) variables below the imports:

```python
import os
import json
import requests

GHUSER = os.getenv('GITHUB_USER')
url = f'https://api.github.com/users/{GHUSER}/events'
```

You can test the globals interactively with `uv run python` in a shell where `GITHUB_USER` is already set: after the imports and assignments, `print(GHUSER)` and `print(url)` should show your username and a well-formed URL.

**5.** Write a function named `retrieve_events` that takes a single parameter `url`. The function must:

- include a docstring describing what it does
- use `requests.get(url).text` to download data from `url`; the result is a JSON text string
- pass that JSON text string to `json.loads(...)` so it becomes a normal Python list/dict
- return that Python object (when the call succeeds, it should be a list of dictionaries containing event information)

**6.** Write a function named `print_events` that takes `events` and an optional parameter `n` with default value `5`. The function must:

- include a docstring describing what it does
- loop over only the first `n` items in `events`
- for each item, print one line in the form `type :: repo`, using the event's `type` field and its nested `repo` → `name` field

Example of the loop body shape (you still need to write the full function, including the docstring and signature):

```python
for x in events[:n]:
    event = x['type'] + ' :: ' + x['repo']['name']
    print(event)
```

**7.** Write a `main` function (with a docstring) that:

- prints the value of `GHUSER`
- prints the value of `url`
- calls `retrieve_events(url)` and stores the returned list
- calls `print_events(...)` with that list (you may pass `n`, or omit it to use the default of `5`)

Then add this entry-point guard at the bottom of the script so `main()` runs only when the file is executed directly (not when imported). Review [class/03-scripting](https://github.com/ksiller/DS2022/blob/main/class/03-scripting/README.md) for how `if __name__ == "__main__"` works:

```python
if __name__ == "__main__":
    main()
```

**8.** Use `chmod` to make your script executable if you like, then run it with `uv` so it uses the project environment:

```bash
chmod +x src/ghevents/github-events.py
uv run python src/ghevents/github-events.py
```

Alternatively, you can activate the virtual environment the traditional way:

```bash
source .venv/bin/activate
python src/ghevents/github-events.py
```

The `source` command updates your shell environment so that `python` resolves to the interpreter in `.venv/bin/` and can import packages installed there (such as `requests`).

Make sure no errors occur. Take a moment to inspect the full API response (for example, temporarily `print(events)` inside `main`) or open the fully formatted URL in a web browser. Note the variety of data available around your work on GitHub.

Much more information is available in the [GitHub API documentation](https://docs.github.com/en/rest?apiVersion=2022-11-28).

**9. Additional Challenges (Optional):**

**Challenge A (local):** Explore the keys contained in the returned JSON data and update the `print_events` function to output additional information for each event. You can do this on your computer without pushing to GitHub.

**Challenge B (portability on HPC):** Test that your Python project runs on another system. This only works after your Script 1 files are on GitHub—complete step (a) before logging into Open OnDemand.

- a. On your computer, from the repository's top-level directory, add, commit, and push your Script 1 work to your fork (do **not** commit `.venv/`):

```bash
git add src/ghevents/ pyproject.toml uv.lock .gitignore .python-version
git commit -m "Add ghevents Script 1 package"
git push origin main
```

- b. Log in to the UVA HPC system: [https://ood.virginia.edu](https://ood.virginia.edu)
- c. In the Open OnDemand dashboard menu, go to **Clusters**, then **HPC shell access** to open a terminal.
- d. In that HPC shell, set `GITHUB_USER` to your GitHub username (your computer's shell config is not used on Rivanna):

```bash
export GITHUB_USER="ksiller"  # replace with your own GitHub username
```

- e. Clone your fork of `lab-03-scripting`, then change into that directory with `cd`.
- f. Execute these commands:

```bash
module load uv
uv run python src/ghevents/github-events.py
```

`uv` will inspect your `pyproject.toml` and `uv.lock` files, create a new virtual environment that matches your project's specs (`.venv/` is recreated on HPC; it was not pushed), and then execute your Python script.

You may finish Challenge B anytime after the checkpoint push in (a), including after Scripts 2–3 or just before Canvas submit.

**Success:** When the script prints recent events without errors on your computer, continue to Script 2. Optional Challenge A can be done now; optional Challenge B can wait until after you push.

## Script 2: Write a Bash script to analyze Moby Dick

**The Case:** A publishing team is preparing an annotated edition of Herman Melville's *Moby Dick* and wants to analyze word frequency across the novel. Searching a 200,000+ word text by hand for many target words is slow and error-prone.

**Your Task:** Write a bash script that searches the novel for a given word, counts how often it appears, and writes a short report to an output file.

### Build the script

**1.** In the repository's top-level directory (`lab-03-scripting`), create a new file `analyze-moby-dick.sh`. Begin the script with a shebang and strict error handling:

```bash
#!/bin/bash
set -euo pipefail
```

(`set -euo pipefail` makes the script exit on errors, unset variables, and failed commands in a pipeline.)

**2.** The `analyze-moby-dick.sh` bash script should automate the following tasks and meet the following specifications:

- a. The script accepts two command-line arguments. The first argument is a string that defines the word to search for; the second argument specifies an output file. Internally, the script stores the value of the first command-line argument in a variable named `SEARCH_PATTERN` and the second in a variable named `OUTPUT`.

- b. Use the `curl` command to download the text of the Moby Dick novel and save it as `mobydick.txt` in the current directory.

  **The URL is:**  
  [https://gist.githubusercontent.com/StevenClontz/4445774/raw/1722a289b665d940495645a5eaaad4da8e3ad4c7/mobydick.txt](https://gist.githubusercontent.com/StevenClontz/4445774/raw/1722a289b665d940495645a5eaaad4da8e3ad4c7/mobydick.txt)

  **Hint:** Review [class/01-cli](https://github.com/ksiller/DS2022/blob/main/class/01-cli/README.md) for using `curl` to download data and save it to a file.

- c. Use the `grep` command to search the `mobydick.txt` file for occurrences of the word specified by the first command-line argument, now stored in the `SEARCH_PATTERN` variable. **Hint:** Look up the `grep -o` option.

- d. Use `wc` to count the number of matches produced by `grep`. **Hint:** Pipes can help here. Store that count in a variable named `OCCURRENCES`.

  **Note:** With `set -euo pipefail`, a `grep` that finds no matches exits with status 1 and will stop the script. For this lab, test with a word you know appears in the novel (for example, `whale`).

- e. Write to the file specified by `OUTPUT` the following message: `The search pattern SEARCH was found N time(s).` Replace `SEARCH` and `N` with the proper variable expressions.

**Success:** If the script runs without errors and writes the expected report, continue to Script 3 or try the optional challenge below.

**Additional Challenge (Optional):**  
Extend the script to handle a few common edge cases and provide richer output:

- a. If the second command-line argument is missing (i.e., no output file specified), the script should write the output to a default file `results.txt`.
- b. If the specified output file already exists, the script should inform the user that the file already exists and abort processing.
- c. In addition to outputting the total number of occurrences, the script will also list the lines in the text where the searched word was found. **Hint:** Check out the `cut` command.
- d. The search should be case-insensitive. **Hint:** Check the documentation for the `grep` command.

This script combines `curl`, `grep`, and `wc` in a short bash pipeline to perform common raw text processing tasks. Next, clean and convert a remote data archive with bash.

## Script 3: Use Bash to clean a data file

**The Case:** You need to turn a remote compressed data bundle into a clean CSV: download an archive, remove blank rows from a tab-separated file, convert it to CSV, count the remaining data rows, and re-package the result.

**Your Task:** Write a bash script named `convert-bundle.sh` that retrieves a remote tar archive, decompresses it, removes blank lines from the dataset, converts the tab-separated file to CSV, reports how many data rows remain, and packages the cleaned CSV into a new compressed archive.

### Build the script

**1.** In the repository's top-level directory (`lab-03-scripting`), create a new file `convert-bundle.sh`. Begin the script with a shebang and strict error handling:

```bash
#!/bin/bash
set -euo pipefail
```

**2.** Using `curl` or `wget`, fetch this tarball:

[https://s3.amazonaws.com/ds2002-resources/labs/lab3-bundle.tar.gz](https://s3.amazonaws.com/ds2002-resources/labs/lab3-bundle.tar.gz)

**3.** Decompress / open the compressed archive using `tar`.

**4.** Remove any empty rows from the dataset. Use **one** of these two approaches (redirect or write the cleaned output to a new file; do not leave it only on the screen):

```bash
# awk can remove blank / whitespace-only lines
awk '!/^[[:space:]]*$/' myfile.tsv > cleaned.tsv

# tr can squeeze repeated newlines
cat myfile.tsv | tr -s '\n' > cleaned.tsv
```

Adjust the input and output filenames to match what you find inside the archive.

**5.** Convert the tab-separated file into a comma-separated (CSV) file. You can do this with tools such as `sed`, `tr`, or `awk` (for example, replace tab characters with commas).

**6.** Add a line of code to count how many lines of data remain in the cleaned file. Remember that row 1 contains headers, so it should not be counted. Another line should `echo` that value to the screen.

**7.** Finally, create a new tarball named `converted-archive.tar.gz` that contains the cleaned CSV file.

**8.** Use `chmod` to make your script executable, and run it. Make sure no errors occur.

**Success:** When the script finishes without errors and produces `converted-archive.tar.gz`, you have finished the coding portion of the lab. Submit your work as described below.

## Submit your work

You created three scripts for this lab (`github-events.py` under `src/ghevents/`, and `analyze-moby-dick.sh` and `convert-bundle.sh` at the repository's top-level directory), plus the `uv` project files needed to run the Python script. Add, commit, and push them to your fork:

```bash
git add src/ghevents/ analyze-moby-dick.sh convert-bundle.sh pyproject.toml uv.lock .gitignore .python-version
git commit -m "Complete lab 03 scripting"
git push origin main
```

If you already pushed Script 1 during Challenge B, add and push any remaining files the same way. Then submit the URL of your forked repository in the text box within Canvas.

## Expected repository layout

When you are finished, your local clone should look similar to this (intermediate download/clean artifacts may also appear in the repository's top-level directory while you work):

```text
lab-03-scripting/
|-- README.md
|-- .gitignore
|-- analyze-moby-dick.sh
|-- convert-bundle.sh
|-- pyproject.toml
|-- uv.lock
|-- .python-version
|-- src/
|   `-- ghevents/
|       |-- __init__.py
|       `-- github-events.py
`-- .venv/
    |-- bin/
    |-- lib/
    `-- pyvenv.cfg
```

Notes:

- Add, commit, and push your work to your fork on GitHub with `git push origin main`.
- Because you set up `.gitignore`, the `.venv` directory will not be tracked or pushed. That is intentional and is general best practice. Others (and graders) can recreate the environment and `.venv` from the `uv.lock` file using `uv sync`.
- `uv init --name ghevents --description "Parse GH events"` creates the package directory `src/ghevents/`. Keep the starter `__init__.py` that `uv` generates, and add `github-events.py` alongside it.
