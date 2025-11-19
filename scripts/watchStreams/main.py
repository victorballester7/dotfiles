import questionary
from rich.console import Console
import subprocess

console = Console()

codeNamesELCANO = { 
    "F1": "fd53cfa7055fe458d4f5c0ff59a06cd43723be55",
    "Moto GP": "b08e158ea3f5c72084f5ff8e3c30ca2e4d1ff6d1",
    "La Liga": "00c9bc9c5d7d87680a5a6bed349edfa775a89947",
}

def makeChoice() -> str:
    """Display a selection menu to the user and return the chosen option."""
    listKeys = list(codeNamesELCANO.keys())
    return questionary.select(
        "Select an option:",
        choices=listKeys,
    ).ask()

def run_mpv(id_stream: str, timeout: int = 10) -> bool:
    """
    Try playing the stream for a short time.
    
    Args:
        id_stream (str): The acestream ID.
        timeout (int): Timeout in seconds.
    
    Returns:
        bool: True if the stream plays without error, False otherwise.
    """
    url = f"http://127.0.0.1:6878/ace/getstream?id={id_stream}"
    console.print(f"[cyan]Testing stream:[/cyan] {id_stream}")
    
    try:
        result = subprocess.run(
            ["mpv", url, "--really-quiet", "--no-terminal"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            timeout=timeout
        )
        # mpv exit code 0 → played fine
        return result.returncode == 0
    except subprocess.TimeoutExpired:
        console.print(f"[yellow]Timeout after {timeout}s[/yellow]")
        return True  # Assume playable if no crash
    except Exception as e:
        console.print(f"[red]Error running mpv:[/red] {e}")
        return False

def main():
    selected = makeChoice()

    id = codeNamesELCANO[selected]

    run_mpv(id)

if __name__ == "__main__":
    main()

