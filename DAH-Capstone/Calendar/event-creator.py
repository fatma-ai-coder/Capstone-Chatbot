import json
import os
from datetime import datetime

# Import the needed classes from your classes file.
# Note: the file has been renamed to "classes_l.py" (instead of "classes-l.py") 
# because a hyphen is not allowed in a Python module name.
from classes_l import Event, Category

# Predefined categories (assuming these already exist)
# We assign them a category_id and a creation timestamp.
predefined_categories = [
    Category("cat1", "Volunteer", datetime.now().isoformat()),
    Category("cat2", "Engineering", datetime.now().isoformat()),
    Category("cat3", "Architechture", datetime.now().isoformat())
]

# The JSON file that stores event information
EVENTS_FILE = "events.json"


def load_events():
    """Load events from the JSON file, or return an empty list if the file doesn't exist."""
    if os.path.exists(EVENTS_FILE):
        with open(EVENTS_FILE, "r") as file:
            try:
                return json.load(file)
            except json.JSONDecodeError:
                return []
    return []


def save_events(events):
    """Save the list of events to the JSON file."""
    with open(EVENTS_FILE, "w") as file:
        json.dump(events, file, indent=4)


def get_event_details():
    """Collects event details from the user and returns an Event instance."""
    event_id = input("Enter Event ID: ").strip()
    title = input("Enter Event Title: ").strip()
    description = input("Enter Event Description: ").strip()
    start_date = input("Enter Start Date (YYYY-MM-DD): ").strip()
    end_date = input("Enter End Date (YYYY-MM-DD): ").strip()
    location = input("Enter Event Location: ").strip()
    admin_input = input("Was this created by an admin? (yes/no): ").strip().lower()
    created_by_admin = True if admin_input == "yes" else False

    # Create the Event instance (the archived flag is False by default)
    new_event = Event(event_id, title, description, start_date, end_date, location, created_by_admin)

    # Process category selection
    event_categories = []
    print("\nExisting Categories:")
    for idx, cat in enumerate(predefined_categories, start=1):
        print(f"{idx}. {cat.name}")

    print("\nYou can select an existing category by number, type a new category name to create one,")
    print("or type 'done' if you are finished selecting categories.")
    
    while True:
        choice = input("Your choice: ").strip()
        if choice.lower() == "done":
            break
        elif choice.isdigit():
            index = int(choice) - 1
            if 0 <= index < len(predefined_categories):
                selected_cat = predefined_categories[index]
                if selected_cat not in event_categories:
                    event_categories.append(selected_cat)
                    print(f"Added category '{selected_cat.name}'.")
                else:
                    print("That category has already been added.")
            else:
                print("Invalid number. Try again.")
        else:
            # Check if the new category already exists (case-insensitive check)
            found = False
            for cat in predefined_categories:
                if cat.name.lower() == choice.lower():
                    found = True
                    if cat not in event_categories:
                        event_categories.append(cat)
                        print(f"Category '{cat.name}' already exists. It has been added.")
                    else:
                        print("That category has already been added.")
                    break
            if not found:
                # Create a new category with a new id
                new_cat_id = f"cat{len(predefined_categories) + 1}"
                new_cat = Category(new_cat_id, choice, datetime.now().isoformat())
                predefined_categories.append(new_cat)
                event_categories.append(new_cat)
                print(f"New category '{choice}' created and added.")

    # Add each category to the event using its add_category method
    for cat in event_categories:
        new_event.add_category(cat)

    return new_event


def main():
    # Get event details from the user.
    event = get_event_details()
    
    # Load any existing events from the JSON file.
    events = load_events()
    
    # Use the event's get_details method to create a dictionary representation.
    events.append(event.get_details())
    
    # Save the updated events list back to the JSON file.
    save_events(events)
    
    print("\nEvent saved successfully to", EVENTS_FILE)


if __name__ == "__main__":
    main()
