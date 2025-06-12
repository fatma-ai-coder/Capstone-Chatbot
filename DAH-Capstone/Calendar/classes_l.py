class User:
    def __init__(self, student_id, name, email, class_level, major):
        self.student_id = student_id
        self.name = name
        self.email = email
        self.class_level = class_level
        self.major = major

    def favorite_event(self, event):
        # Logic to mark an event as favorite
        pass

    def view_favorites(self):
        # Logic to view favorite events
        pass

    def register_for_event(self, event):
        # Logic to register for an event
        pass

    def unregister_event(self, event):
        # Logic to unregister from an event
        pass


class Favorite:
    def __init__(self, favorite_id, student_id, event_id):
        self.favorite_id = favorite_id
        self.student_id = student_id
        self.event_id = event_id

    @staticmethod
    def add_favorite(student, event):
        # Logic to add an event to a student's favorites
        pass

    def remove_favorite(self):
        # Logic to remove a favorite event
        pass


class Event:
    def __init__(self, event_id, title, description, start_date, end_date, location, created_by_admin, archived=False):
        self.event_id = event_id
        self.title = title
        self.description = description
        self.start_date = start_date
        self.end_date = end_date
        self.location = location
        self.created_by_admin = created_by_admin
        self.archived = archived
        self.categories = []  # List of associated categories

    def update_event(self, **kwargs):
        # Logic to update event details
        for key, value in kwargs.items():
            if hasattr(self, key):
                setattr(self, key, value)

    def archive_event(self):
        self.archived = True

    def add_category(self, category):
        if category not in self.categories:
            self.categories.append(category)

    def remove_category(self, category):
        if category in self.categories:
            self.categories.remove(category)

    def get_details(self):
        return {
            "event_id": self.event_id,
            "title": self.title,
            "description": self.description,
            "start_date": self.start_date,
            "end_date": self.end_date,
            "location": self.location,
            "created_by_admin": self.created_by_admin,  # Make sure this is here
            "categories": [category.name for category in self.categories],
            "archived": self.archived
        }


class EventCategory:
    def __init__(self, event_id, category_id):
        self.event_id = event_id
        self.category_id = category_id

    def get_event_category_details(self):
        # Logic to retrieve details for the event-category link
        pass


class Category:
    def __init__(self, category_id, name, created_at):
        self.category_id = category_id
        self.name = name
        self.created_at = created_at

    def update_category(self, **kwargs):
        # Logic to update category details
        for key, value in kwargs.items():
            if hasattr(self, key):
                setattr(self, key, value)
