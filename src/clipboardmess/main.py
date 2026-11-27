import random
from pathlib import Path
from time import sleep

import pyperclip


def main() -> None:
    prompt_file = Path(__file__).with_name("prompts.txt")
    prompts = [line.strip() for line in prompt_file.read_text(encoding="utf-8").splitlines() if line.strip()]
    if not prompts:
        raise RuntimeError("prompts.txt must contain at least one prompt")

    previous_content = None
    while True:
        try:
            current_content = pyperclip.paste()
            if previous_content is not None and current_content != previous_content:
                if random.randint(0, 200) == 0:
                    current_content = random.choice(prompts)
                    pyperclip.copy(current_content)
            previous_content = current_content
        except pyperclip.PyperclipWindowsException:
            # Another application can hold the Windows clipboard open briefly.
            pass

        sleep(0.5)


if __name__ == "__main__":
    main()
