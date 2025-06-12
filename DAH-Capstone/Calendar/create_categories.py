import json
import os
from datetime import datetime
from classes_l import Category  # Import your Category class

CATEGORIES_FILE = "categories.json"

def load_categories():
    """Load categories from the JSON file. Returns a list of Category objects."""
    categories = []
    if os.path.exists(CATEGORIES_FILE):
        with open(CATEGORIES_FILE, "r") as file:
            try:
                data = json.load(file)
                for cat_dict in data:
                    # Re-create the Category object from the dictionary.
                    categories.append(Category(
                        cat_dict["category_id"],
                        cat_dict["name"],
                        cat_dict["created_at"]
                    ))
            except json.JSONDecodeError:
                pass
    return categories

def save_categories(categories):
    """Save a list of Category objects to the JSON file."""
    data = []
    for cat in categories:
        data.append({
            "category_id": cat.category_id,
            "name": cat.name,
            "created_at": cat.created_at
        })
    with open(CATEGORIES_FILE, "w") as file:
        json.dump(data, file, indent=4)

def generate_category_id(categories):
    """Generate the next serialized category ID starting from 100."""
    if categories:
        max_id = max(int(cat.category_id) for cat in categories)
        return str(max_id + 1)
    else:
        return "100"

def list_categories(categories):
    if not categories:
        print("No categories available.")
    else:
        print("Existing Categories:")
        for cat in categories:
            print(f"  ID: {cat.category_id} - Name: {cat.name}")

def main():
    categories = load_categories()
    list_categories(categories)

    while True:
        new_cat = input("\nEnter a new category name to add (or type 'done' to exit): ").strip()
        if new_cat.lower() == "done":
            break

        # Check if a category with that name (case-insensitive) already exists.
        if any(cat.name.lower() == new_cat.lower() for cat in categories):
            print("This category already exists.")
        else:
            new_cat_id = generate_category_id(categories)
            created_at = datetime.now().isoformat()
            category = Category(new_cat_id, new_cat, created_at)
            categories.append(category)
            save_categories(categories)
            print(f"Category '{new_cat}' added with ID {new_cat_id}.")

    print("\nFinal list of categories:")
    list_categories(categories)

if __name__ == "__main__":
    main()
