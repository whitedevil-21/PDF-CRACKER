import sys
import os
import pikepdf
from colorama import init, Fore, Style

# Initialize colorama for colored output
init(autoreset=True)

def crack_pdf(pdf_path, wordlist_path):
    # Check if files exist
    if not os.path.exists(pdf_path):
        print(Fore.RED + "[!] Error: PDF file not found.")
        return
    if not os.path.exists(wordlist_path):
        print(Fore.RED + "[!] Error: Wordlist file not found.")
        return

    print(Fore.CYAN + f"[*] Target: {pdf_path}")
    print(Fore.CYAN + f"[*] Using Wordlist: {wordlist_path}")
    print(Fore.YELLOW + "[*] Starting attack...\n")

    found = False
    
    # Open the wordlist with 'latin-1' encoding to avoid errors with weird characters
    with open(wordlist_path, 'r', encoding='latin-1', errors='ignore') as f:
        passwords = f.readlines()
        total_passwords = len(passwords)
        
        for index, password in enumerate(passwords):
            password = password.strip()
            
            # Progress indicator (optional, remove if you want silence)
            # using \r to overwrite the line keeps the terminal clean
            print(Fore.YELLOW + f"\r[{index+1}/{total_passwords}] Trying: {password}", end="")

            try:
                # Attempt to open the PDF
                with pikepdf.open(pdf_path, password=password) as pdf:
                    print(f"\n{'-'*30}")
                    print(Fore.GREEN + Style.BRIGHT + f"[+] PASSWORD FOUND: {password}")
                    print(f"{'-'*30}")
                    found = True
                    break
            except pikepdf.PasswordError:
                continue
            except Exception as e:
                print(f"\n{Fore.RED}[!] Error: {e}")
                continue

    if not found:
        print(f"\n{Fore.RED}[-] Password not found in the provided wordlist.")

if __name__ == "__main__":
    try:
        # User Inputs
        print(Fore.BLUE + Style.BRIGHT + "--- PDF CRACKER TOOL ---")
        pdf_file = input(Fore.WHITE + "Enter path to PDF file: ").strip().strip("'").strip('"')
        wordlist_file = input(Fore.WHITE + "Enter path to Wordlist: ").strip().strip("'").strip('"')
        
        crack_pdf(pdf_file, wordlist_file)
        
    except KeyboardInterrupt:
        print(f"\n{Fore.RED}[!] Process stopped by user.")
