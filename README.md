# Lab 03: Scripting

The goal of this activity is to get you comfortable with writing scripts in Python and bash. You will practice working with environment variables, making API requests, and handling user input. Follow the steps below to create scripts that demonstrate these fundamental scripting concepts.

## Setup

For the Python scripts in this lab, you will need Python 3 and the [uv](https://docs.astral.sh/uv/) package manager installed on your computer.

**Confirm that both are installed:**  
Open a terminal window and run these commands (if you're on a Windows system, make sure you are in a WSL bash terminal, not PowerShell).

```bash
which python3
python3 -V
```

That path should be something like `/usr/bin/python3`, and the version should be >3.11.

```bash
uv --version
```

If this command fails with an error, install uv using this command:

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

## Script 1: Use Python to fetch remote data

**The Case:** A team wants a simple view of recent GitHub activity for a developer account. Checking profiles by hand does not scale, so they want a small script that calls the GitHub API and prints recent events.

**Your Task:** Set up a Python project with `uv`, install the `requests` library, and write a script that fetches and displays recent GitHub activity for a user stored in an environment variable.

**Setup (uv project + `requests`):**

1. Log in to GitHub and fork this repository: <https://github.com/ksiller/lab-03-scripting>.

2. Clone your fork locally, then change into the `lab-03-scripting` folder.

3. Confirm that you are in the repo root (`lab-03-scripting`), then initialize a `uv` project:

```bash
uv init --name ghevents --description "Parse GH events"
```

This command creates (or updates) the project files `uv` needs, typically `pyproject.toml`, a hidden `.python-version` file, and a `src/ghevents/` package directory.

- **pyproject.toml**: Open this file in your Cursor editor (or run `cat pyproject.toml` in your terminal). Notice the `name` and `description` fields; their values match the command-line options you passed to `uv init`. Also notice that the `dependencies` field is defined as an empty list `[]`.
- **.python-version**: This is likely the Python version `uv` found when it ran `uv init`. You can change the version if you prefer a different one.
- **src/ghevents/**: This is where your Python script(s) belong. Initially it contains `__init__.py`, which makes your project importable by other Python scripts or projects.

Add the `requests` package:

```bash
uv add requests
```

The following will happen:

- **pyproject.toml**: The `dependencies` field now contains an entry for `requests`. By default it is pinned to the latest version available when the `uv add` command was executed.
- **uv.lock**: A declarative description of the exact Python package versions added to your project. Scroll down to `requests` and note that it has a specific version. **This makes your environment exactly reproducible on other systems. Do not edit it manually!**
- **.venv**: A new hidden directory with `lib` and `bin` subfolders and a few additional files that help manage an isolated environment for your Python project and its dependency packages. Check the `lib` folder; this is where the `requests` package (along with its own dependencies) was installed.

Create a `.gitignore` file in the repo root so Git does not track the virtual environment:

```bash
echo ".venv/" >> .gitignore
```

Or create `.gitignore` in your editor and add this line:

```gitignore
.venv/
```

**Let's Build It:**

1. Create a new script called `github-events.py` in `src/ghevents/` (the package directory created by `uv init`), and open it in an editor.

2. Put your Python 3 path in a shebang line. Use the command below to find your path to Python:

    ```bash
    which python3
    ```

    For the shebang, use the more flexible `/usr/bin/env python3` form (see lecture slides). Because dependencies live in the `uv` environment, run the finished script with `uv run` (shown in step 7) so `requests` is available.

3. For this script you will need to set an environment variable in your shell. Edit your `~/.bashrc` file (or `~/.zshrc`) and export a new variable named `GITHUB_USER`. Give it the value of your own GitHub username.

    ```bash
    export GITHUB_USER="ksiller"  # replace with your own GitHub username
    ```

    After you add this line, run `source ~/.bashrc` (or `source ~/.zshrc`) to load the new value into your environment.

4. Back to your Python script. To work with environment variables and remote APIs you need three imports:

    ```python
    import os
    import json
    import requests
    ```

    To retrieve the value of an environment variable in Python, use this syntax:

    ```python
    GHUSER = os.getenv('GITHUB_USER')
    ```

    You can test that this works by using Python interactively (`uv run python`). Load your imports and execute that line, then `print(GHUSER)` to confirm your username.

5. Next, use this variable to fetch the recent activity for this user account (you!) on GitHub. First configure the remote endpoint. The format for that API address is:

    ```
    https://api.github.com/users/USERNAME/events
    ```

    To dynamically insert your `GITHUB_USER` name into this URL, define a `url` variable like this:

    ```python
    url = f'https://api.github.com/users/{GHUSER}/events'
    ```

    You will know if this is formatted correctly if you `print(url)` within Python and see a well-formed address.

6. Use this address to fetch your recent GitHub activity with the `requests` library. Load the response from the API into a variable, and loop through the first five events:

    ```python
    r = json.loads(requests.get(url).text)

    for x in r[:5]:
      event = x['type'] + ' :: ' + x['repo']['name']
      print(event)
    ```

    Take a moment to `print(r)` and view all the results. You can also do this by opening the fully formatted URL in a web browser. Note the variety of data available around your work on GitHub.

    Much more information is available in the [GitHub API documentation](https://docs.github.com/en/rest?apiVersion=2022-11-28).

7. Use `chmod` to make your script executable if you like, then run it with `uv` so it uses the project environment:

    ```bash
    chmod +x src/ghevents/github-events.py
    uv run python src/ghevents/github-events.py
    ```

    Make sure no errors occur.

To run Python commands inside the project environment, use:

```bash
uv run python src/ghevents/github-events.py
```

Alternatively, you can activate the virtual environment the traditional way:

```bash
source .venv/bin/activate
python src/ghevents/github-events.py
```

The `source` command updates your shell environment so that `python` resolves to the interpreter in `.venv/bin/` and can import packages installed there (such as `requests`).

8. **Additional Challenges (Optional):**

   - Explore the keys contained in the returned JSON data and output additional information for each event.
   - Test portability of your package on another system:
     a. Log in to the UVA HPC system: <https://ood.virginia.edu>
     b. In the Open OnDemand dashboard menu, go to **Clusters** > **HPC shell access** to open a terminal.
     c. In the terminal, clone your fork of `lab-03-scripting`.
     d. Change into `lab-03-scripting` with the `cd` command.
     e. Execute these commands:

        ```bash
        module load uv
        uv run python src/ghevents/github-events.py
        ```

        `uv` will inspect your `pyproject.toml` and `uv.lock` files, create a new virtual environment that matches your project's specs, and then execute your Python script.

**Success:** When the script prints recent events without errors, continue to Script 2 to practice bash text processing, or try the optional challenges above.

## Script 2: Write a Bash script to analyze Moby Dick

**The Case:** A publishing team is preparing an annotated edition of Herman Melville's *Moby Dick* and wants to analyze word frequency across the novel. Searching a 200,000+ word text by hand for many target words is slow and error-prone.

**Your Task:** Write a bash script that searches the novel for a given word, counts how often it appears, and writes a short report to an output file.

**Let's Build It:**

1. In the repo root (`lab-03-scripting`), create a new file `analyze-moby-dick.sh`. Begin the script with a shebang and strict error handling:

   ```bash
   #!/bin/bash
   set -euo pipefail
   ```

   (`set -euo pipefail` makes the script exit on errors, unset variables, and failed commands in a pipeline.)

2. The `analyze-moby-dick.sh` bash script should automate the following tasks and meet the following specifications:

   a. The script accepts two command-line arguments. The first argument is a string that defines the word to search for; the second argument specifies an output file. Internally, the script stores the value of the first command-line argument in a variable named `SEARCH_PATTERN` and the second in a variable named `OUTPUT`.

   b. Use the `curl` command to download the text of the Moby Dick novel and save it as `mobydick.txt` in the current directory.

   **The URL is:**  
   <https://gist.githubusercontent.com/StevenClontz/4445774/raw/1722a289b665d940495645a5eaaad4da8e3ad4c7/mobydick.txt>

   **Hint:** Review [class/01-cli](https://github.com/ksiller/DS2022/blob/main/class/01-cli/README.md) for using `curl` to download data and save it to a file.

   c. Use the `grep` command to search the `mobydick.txt` file for occurrences of the word specified by the first command-line argument, now stored in the `SEARCH_PATTERN` variable. **Hint:** Look up the `grep -o` option.

   d. Use `wc` to count the number of occurrences of the `SEARCH_PATTERN` returned by `grep`. **Hint:** Pipes can be of great help here. Store that number in a new variable `OCCURRENCES`.

   e. Write to the file specified by `OUTPUT` the following message: `The search pattern <S> was found <N> time(s).` Replace `<S>` and `<N>` with the proper variable expressions.

   **Success:** If the script runs without errors and writes the expected report, continue to Script 3 or try the optional challenge below.

   **Additional Challenge (Optional):**  
   Extend the script to handle a few common edge cases and provide richer output:

   a. If the second command-line argument is missing (i.e., no output file specified), the script should write the output to a default file `results.txt`.

   b. If the specified output file already exists, the script should inform the user that the file already exists and abort processing.

   c. In addition to outputting the total number of occurrences, the script will also list the lines in the text where the searched word was found. **Hint:** Check out the `cut` command.

   d. The search should be case-insensitive. **Hint:** Check the documentation for the `grep` command.

This script combines `curl`, `grep`, and `wc` in a short bash pipeline to perform common raw text processing tasks. Next, clean and convert a remote data archive with bash.

## Script 3: Use Bash to clean a data file

**The Case:** You need to turn a remote compressed data bundle into a clean CSV: download an archive, remove blank rows from a tab-separated file, convert it to CSV, count the remaining data rows, and re-package the result.

**Your Task:** Write a bash script named `convert-bundle.sh` that retrieves a remote tar archive, decompresses it, removes blank lines from the dataset, converts the tab-separated file to CSV, reports how many data rows remain, and packages the cleaned CSV into a new compressed archive.

**Let's Build It:**

1. In the repo root (`lab-03-scripting`), create a new file `convert-bundle.sh`. Begin the script with a shebang and strict error handling:

   ```bash
   #!/bin/bash
   set -euo pipefail
   ```

2. Using `curl` or `wget`, fetch this tarball:

   <https://s3.amazonaws.com/ds2002-resources/labs/lab3-bundle.tar.gz>

3. Decompress / open the compressed archive using `tar`.

4. Remove any empty rows from the dataset. Use **one** of these two approaches:

   ```bash
   # awk can remove blank / whitespace-only lines
   awk '!/^[[:space:]]*$/' myfile.tsv

   # tr can squeeze repeated newlines
   cat myfile.tsv | tr -s '\n' > my_new_file.tsv
   ```

   Adjust the input and output filenames to match what you find inside the archive.

5. Convert the tab-separated file into a comma-separated (CSV) file. You can do this with tools such as `sed`, `tr`, or `awk` (for example, replace tab characters with commas).

6. Add a line of code to count how many lines of data remain in the cleaned file. Remember that row 1 contains headers, so it should not be counted. Another line should `echo` that value to the screen.

7. Finally, create a new tarball named `converted-archive.tar.gz` that contains the cleaned CSV file.

8. Use `chmod` to make your script executable, and run it. Make sure no errors occur.

**Success:** When the script finishes without errors and produces `converted-archive.tar.gz`, you have finished the coding portion of the lab. Submit your work as described below.

## Submit your work

You created three scripts for this lab (`github-events.py` under `src/ghevents/`, and `analyze-moby-dick.sh` and `convert-bundle.sh` at the repo root), plus the `uv` project files needed to run the Python script. Add, commit, and push them to your fork. Then submit the URL of your forked repository in the text box within Canvas.

## Expected repository layout

When you are finished, your local clone should look similar to this (intermediate download/clean artifacts may also appear in the repo root while you work):

```text
lab-03-scripting/
├── README.md
├── .gitignore
├── analyze-moby-dick.sh
├── convert-bundle.sh
├── pyproject.toml
├── uv.lock
├── .python-version
├── src/
│   └── ghevents/
│       ├── __init__.py
│       └── github-events.py
└── .venv/
    ├── bin/
    ├── lib/
    └── pyvenv.cfg
```

Notes:

- Add, commit, and push your work to your fork on GitHub.
- Because you set up `.gitignore`, the `.venv` directory will not be tracked or pushed. That is intentional and is general best practice. Others (and graders) can recreate the environment and `.venv` from the `uv.lock` file using `uv sync`.
- `uv init --name ghevents --description "Parse GH events"` creates the package directory `src/ghevents/`. Keep the starter `__init__.py` that `uv` generates, and add `github-events.py` alongside it.
