# Word Table Processor Program

This program is designed to process a table of words (NUMS) and perform a series of operations based on instructions from CHANGES and SWITCHES tables. NUMS contains 7 rows with 9 words per row, while CHANGES and SWITCHES tables provide sequences that adjust and rearrange words in NUMS accordingly.

The program demonstrates structured data manipulation and file I/O in x86 assembly.

## 🧮 Program Flow
1. Print the Unsorted NUMS Table: Displays the NUMS table in its original 7-row by 9-column format.
2. Sort Rows of NUMS: Sorts each row of NUMS in ascending order (treating the words as signed data) and prints the sorted table.
3. Apply Increment Values (CHANGES Table): Each sequence in the CHANGES table specifies a row, a column, and an increment value. The program adjusts the specified words and prints the modified table.
4. Switch Words (SWITCHES Table): Each sequence in SWITCHES specifies two positions to swap words within NUMS. The program performs all switches and prints the final table.

## ✨ Program Features
- Output Choice: At the start, the user selects whether to display the output on the screen or save it to a file.
- File Handling: If file output is chosen, the program prompts the user to specify a filename. If the file already exists, the program ensures it isn’t overwritten.
- Assembly Language Interaction: All user prompts and file operations are managed using assembly language routines (such as Irvine’s WriteString, ReadString, and WriteFile).

## 🧰 Dependencies
- This project uses the **Irvine32** library for input/output and file handling in x86 assembly.
- To build and run the program, ensure Irvine32 is installed and configured for **32-bit MASM projects in Visual Studio**, following the official setup instructions:
https://asmirvine.com  
→ *Getting Started with MASM and Visual Studio 2022*  
→ *Required Setup for 32-bit Applications*  
  
## 📊 Tables:
- NUMS: The main 7x9 table of words to be processed.
- CHANGES: Contains sequences for modifying values in NUMS.
- SWITCHES: Contains sequences for swapping specific positions in NUMS.

## ▶️ Usage
### Running the Program
1. Compile and execute the program in an environment that supports the Irvine32 library.
2. Choose Output Method:
  - Screen: Displays all tables to the console.
  - File: Saves the output to a user-specified file. This includes four tables (unsorted, sorted, changed, and switched), separated by blank lines.
### Output Tables
- Unsorted Table: The original NUMS table.
- Sorted Table: The NUMS table with each row sorted independently.
- Changed Table: The NUMS table after applying increments from the CHANGES table.
- Switched Table: The NUMS table after applying switches from the SWITCHES table.

## 🧪 Example Tables
- Example of NUMS table, sample CHANGES table, and SWITCHES table data are provided in the code comments for testing and illustration.
- Modify table values and sequences in the program code for testing various cases.

## 📜 License
This project is licensed under the MIT License. See the LICENSE file for details.

## 👤 Author
Hannah G. Simon
