# import questionary
# import requests
# from bs4 import BeautifulSoup
# import re
# import json
# from typing import List

# codeNamesELCANO = { 
#     "F1": "DAZN F1 1080",
#     "Moto GP": "DAZN 1",
#     "La Liga": "La Liga 1080",
# }

# def makeChoice() -> str:
#     """
#     Presents a selection menu to the user and returns the selected option.\
#     
#     Returns:
#         str: The selected option from the menu.
#     """
#     listKeys = [str(key) for key in codeNamesELCANO.keys()]
#     return questionary.select(
#         "Select an option:",
#         choices=listKeys,
#     ).ask()

# def getStreamID(selected) -> List[str]:
#     url = "https://ipfs.io/ipns/elcano.top"

#     response = requests.get(url)
#     response.raise_for_status()

#     soup = BeautifulSoup(response.text, "html.parser")

#     # read html script tag
#     script_tag = soup.script
#     script_content = script_tag.string if script_tag else None

#     if script_content:
#         # Extract the JSON part using regex
#         json_match = re.search(r'const linksData = ({.*?});', script_content, re.DOTALL)
#         if json_match:
#             json_str = json_match.group(1)
#             links_data = json.loads(json_str)
#         else:
#             print("No JSON data found in the script content")
#             return
#         
#         # Filter for DAZN F1 1080 links
#         linksSelected = []
#         for l in links_data['links']:
#             if codeNamesELCANO[selected] in l['name']:
#                 linksSelected.append(
#                         l['url'].replace("acestream://", "")
#                 )
#     else:
#         print("No script content found")
#         return
#     
#     return linksSelected

# def main():
#     # get option to watch
#     selected = makeChoice()
#     print(f"You selected: {selected}")

#     ids = getStreamID(selected)

#     print(ids)


# if __name__ == "__main__":
#     main()


import questionary
import requests
from bs4 import BeautifulSoup
import re
import json
from typing import List, Optional
from rich import print
from rich.console import Console
from rich.panel import Panel
from rich.progress import Progress, SpinnerColumn, TextColumn
import subprocess
import time

console = Console()

codeNamesELCANO = { 
    "F1": "DAZN F1 1080",
    "Moto GP": "DAZN 1",
    "La Liga": "La Liga 1080",
}

IPFS_GATEWAYS = [
    "https://ipfs.io/ipns/elcano.top",
    # "https://cloudflare-ipfs.com/ipns/elcano.top",
    # "https://gateway.pinata.cloud/ipns/elcano.top"
]

def makeChoice() -> str:
    """Display a selection menu to the user and return the chosen option."""
    listKeys = list(codeNamesELCANO.keys())
    return questionary.select(
        "Select an option:",
        choices=listKeys,
    ).ask()

def fetch_page() -> Optional[str]:
    """Try multiple gateways until one returns content."""
    for gateway in IPFS_GATEWAYS:
        console.print(f"[cyan]Trying gateway:[/cyan] {gateway}")
        try:
            response = requests.get(gateway, timeout=10)
            response.raise_for_status()
            console.print(f"[green]Success![/green] Using gateway: {gateway}")
            return response.text
        except requests.RequestException as e:
            console.print(f"[yellow]Gateway failed:[/yellow] {gateway} ({e})")
    console.print("[red]All gateways failed.[/red]")
    return None

def getStreamID(selected: str) -> List[str]:
    """Extract all AceStream IDs for the selected channel."""
    html = fetch_page()
    if html is None:
        return []

    soup = BeautifulSoup(html, "html.parser")
    script_tag = soup.script
    script_content = script_tag.string if script_tag else None

    if not script_content:
        console.print("[red]No <script> tag found in HTML.[/red]")
        return []

    json_match = re.search(r'const\s+linksData\s*=\s*({.*?});', script_content, re.DOTALL)
    if not json_match:
        console.print("[red]No JSON-like data found in script.[/red]")
        return []

    try:
        links_data = json.loads(json_match.group(1))
    except json.JSONDecodeError as e:
        console.print(f"[red]Failed to parse JSON:[/red] {e}")
        return []

    linksSelected = [
        link["url"].replace("acestream://", "")
        for link in links_data.get("links", [])
        if codeNamesELCANO[selected] in link.get("name", "")
    ]

    if not linksSelected:
        console.print(f"[yellow]No streams found for {selected}.[/yellow]")

    return linksSelected

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


def play(ids: List[str]) -> None:
    """
    Ask the user for a stream ID, or test all until one works.
    """
    with Progress(SpinnerColumn(), TextColumn("[progress.description]{task.description}"), console=console) as progress:
        task = progress.add_task("Testing streams...", total=None)
        for stream_id in ids:
            if run_mpv(stream_id, timeout=10):
                console.print(f"[green]✅ Stream works:[/green] {stream_id}")
                subprocess.run(["mpv", f"http://127.0.0.1:6878/ace/getstream?id={stream_id}"])
                break
        else:
            console.print("[bold red]❌ No working streams found[/bold red]")
        progress.remove_task(task)
def main():
    console.print(Panel.fit("[bold cyan]Stream Finder[/bold cyan]", style="blue"))

    selected = makeChoice()
    console.print(f"[bold]You selected:[/bold] [green]{selected}[/green]")

    ids = getStreamID(selected)
    if ids:
        console.print("[bold cyan]Available Stream IDs:[/bold cyan]")
        for idx, stream_id in enumerate(ids, start=1):
            console.print(f" {idx}. [magenta]{stream_id}[/magenta]")
    else:
        console.print("[red]No streams available.[/red]")

    play(ids)

if __name__ == "__main__":
    main()

