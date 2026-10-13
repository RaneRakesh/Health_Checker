# Agent Instructions & Project Rules

## Project Memory & Fast Context Rule
1. **`brain.md` as Single Source of Truth:**
   - Whenever the user gives the command **"check brain.md file"** (or asks for project status, architecture, or codebase review), always read and consult [`brain.md`](file:///home/credentek/dartpedia/Health_Checker/brain.md) first instead of scanning and reading the entire project repository from scratch.
2. **Synchronize Changes:**
   - Whenever any new feature, file, model, API endpoint, or dependency is introduced, updated, or removed, update [`brain.md`](file:///home/credentek/dartpedia/Health_Checker/brain.md) to keep it in sync.
