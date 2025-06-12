import json
import os
from datetime import datetime
from classes_l import Event, Category  # Import your Event and Category classes

EVENTS_FILE = "events.json"
CATEGORIES_FILE = "categories.json"

def load_events():
    """Load events from the JSON file. Returns a list of event dictionaries."""
    if os.path.exists(EVENTS_FILE):
        with open(EVENTS_FILE, "r") as file:
            try:
                return json.load(file)
            except json.JSONDecodeError:
                return []
    return []

def save_events(events):
    """Save the list of event dictionaries to the JSON file."""
    with open(EVENTS_FILE, "w") as file:
        json.dump(events, file, indent=4)

def load_categories():
    """Load categories from the JSON file and return a list of Category objects."""
    categories = []
    if os.path.exists(CATEGORIES_FILE):
        with open(CATEGORIES_FILE, "r") as file:
            try:
                data = json.load(file)
                for cat_dict in data:
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

def generate_event_id():
    """
    Generate a serialized event ID.
    The first event will have an ID of 2500. Subsequent events increment by 1.
    """
    events = load_events()
    if events:
        max_id = max(int(event["event_id"]) for event in events)
        return str(max_id + 1)
    else:
        return "2500"

def generate_category_id(categories):
    """
    Generate a serialized category ID starting at 100.
    """
    if categories:
        max_id = max(int(cat.category_id) for cat in categories)
        return str(max_id + 1)
    else:
        return "100"

def get_event_details():
    """Collect event details from the user and return an Event instance."""
    # Auto-generate the event ID.
    event_id = generate_event_id()
    print(f"Generated Event ID: {event_id}")
    
    title = input("Enter Event Title: ").strip()
    description = input("Enter Event Description: ").strip()
    start_date = input("Enter Start Date (YYYY-MM-DD): ").strip()
    end_date = input("Enter End Date (YYYY-MM-DD): ").strip()
    location = input("Enter Event Location: ").strip()
    # Now, created_by_admin stores the admin's name.
    created_by_admin = input("Enter the name of the admin who created this event: ").strip()

    # Create the Event instance (assume archived defaults to False).
    new_event = Event(event_id, title, description, start_date, end_date, location, created_by_admin)

    # Load the current categories from the JSON file.
    categories = load_categories()

    # Process category selection.
    event_categories = []
    if categories:
        print("\nExisting Categories:")
        for idx, cat in enumerate(categories, start=1):
            print(f"{idx}. {cat.name} (ID: {cat.category_id})")
    else:
        print("\nNo existing categories found.")

    print("\nYou can select an existing category by number, type a new category name to create one,")
    print("or type 'done' if you are finished selecting categories.")

    while True:
        choice = input("Your choice: ").strip()
        if choice.lower() == "done":
            break
        elif choice.isdigit():
            index = int(choice) - 1
            if 0 <= index < len(categories):
                selected_cat = categories[index]
                if selected_cat not in event_categories:
                    event_categories.append(selected_cat)
                    print(f"Added category '{selected_cat.name}'.")
                else:
                    print("That category has already been added.")
            else:
                print("Invalid number. Try again.")
        else:
            # Check if the category already exists (case-insensitive).
            found = False
            for cat in categories:
                if cat.name.lower() == choice.lower():
                    found = True
                    if cat not in event_categories:
                        event_categories.append(cat)
                        print(f"Category '{cat.name}' already exists and has been added.")
                    else:
                        print("That category has already been added.")
                    break
            if not found:
                # Create a new category with a new category ID.
                new_cat_id = generate_category_id(categories)
                created_at = datetime.now().isoformat()
                new_cat = Category(new_cat_id, choice, created_at)
                categories.append(new_cat)
                event_categories.append(new_cat)
                print(f"New category '{choice}' created with ID {new_cat_id} and added.")
                # Save the updated categories list.
                save_categories(categories)

    # Associate the selected categories with the event using its add_category method.
    for cat in event_categories:
        new_event.add_category(cat)

    return new_event

def main():
    # Get event details from the user.
    event = get_event_details()
    
    # Load any existing events from the JSON file.
    events = load_events()
    
    # Append the new event's details.
    events.append(event.get_details())
    
    # Save the updated events list.
    save_events(events)
    
    print(f"\nEvent saved successfully to {EVENTS_FILE}")

if __name__ == "__main__":
    main()
