from datetime import datetime
from typing import List

# Category class represents different types of events (e.g., Technology, Arts, Sports)
class Category:
    def __init__(self, categoryId: str, name: str, createdAt: datetime):
        # Unique identifier for the category
        self.categoryId = categoryId
        # Name of the category
        self.name = name
        # Timestamp when category was created
        self.createdAt = createdAt
        # List to store related category IDs (relationships between categories)
        self.categoryIdList: List[str] = []

    def updateCategory(self, name: str):
        # Method to update category name
        self.name = name

# Event class represents individual events in the system
class Event:
    def __init__(self, eventId: str, title: str, description: str, startDate: datetime, endDate: datetime,
                 location: str, categoryId: str, createdByAdmin: str):
        # Basic event information
        self.eventId = eventId          # Unique identifier for the event
        self.title = title              # Event title
        self.description = description  # Event description
        self.startDate = startDate      # Event start date and time
        self.endDate = endDate          # Event end date and time
        self.location = location        # Event location
        
        # Store categoryId as a list for multiple categories
        self.categoryId: List[str] = [categoryId]
        
        # Administrative information
        self.createdByAdmin = createdByAdmin  # ID of admin who created event
        self.archived = False                 # Flag for archived events
        
        # List to store IDs of registered students
        self.registered_students: List[str] = []

    def updateEvent(self, title: str = None, description: str = None, startDate: datetime = None,
                   endDate: datetime = None, location: str = None):
        # Method to update event details
        # Only updates fields that are provided (not None)
        if title:
            self.title = title
        if description:
            self.description = description
        if startDate:
            self.startDate = startDate
        if endDate:
            self.endDate = endDate
        if location:
            self.location = location

    def archiveEvent(self):
        # Mark event as archived (inactive)
        self.archived = True

    def addCategory(self, category: Category):
        # Add a category to the event if not already present
        if category.categoryId not in self.categoryId:
            self.categoryId.append(category.categoryId)

    def removeCategory(self, category: Category):
        # Remove a category from the event if present
        if category.categoryId in self.categoryId:
            self.categoryId.remove(category.categoryId)

    def registerStudent(self, studentId: str):
        # Register a student for the event if not already registered
        if studentId not in self.registered_students:
            self.registered_students.append(studentId)

    def unregisterStudent(self, studentId: str):
        # Remove a student's registration from the event
        if studentId in self.registered_students:
            self.registered_students.remove(studentId)

    def getDetails(self):
        # Return all event details as a dictionary
        return {
            "eventId": self.eventId,
            "title": self.title,
            "description": self.description,
            "startDate": self.startDate,
            "endDate": self.endDate,
            "location": self.location,
            "categoryId": self.categoryId,
            "createdByAdmin": self.createdByAdmin,
            "archived": self.archived,
            "registered_students": self.registered_students
        }

# User class represents students who can register for events
class User:
    def __init__(self, studentId: str, name: str, email: str, class_level: str, major: str):
        # Student information
        self.studentId = studentId    # Unique identifier for the student
        self.name = name              # Student's name
        self.email = email            # Student's email
        self.class_level = class_level  # Academic level (e.g., Freshman, Senior)
        self.major = major            # Student's major
        
        # List to store favorite events
        self.favorites: List[Favorite] = []

    def favoriteEvent(self, event: Event):
        # Add an event to student's favorites if not already favorited
        favorite = Favorite(self.studentId, event.eventId)
        if favorite not in self.favorites:
            self.favorites.append(favorite)

    def viewFavorites(self):
        # Return list of favorited event IDs
        return [favorite.eventId for favorite in self.favorites]

# Favorite class represents the relationship between a student and their favorited event
class Favorite:
    def __init__(self, studentId: str, eventId: str):
        # Create unique identifier for the favorite relationship
        self.favoriteId = f"fav-{studentId}-{eventId}"
        self.studentId = studentId  # ID of student who favorited
        self.eventId = eventId      # ID of favorited event


# Helper functions for managing favorites
def addFavorite(student: User, event: Event):
    # Add event to student's favorites
    student.favoriteEvent(event)

def removeFavorite(student: User, event: Event):
    # Remove event from student's favorites
    student.favorites = [fav for fav in student.favorites if fav.eventId != event.eventId]

# EventCategory class represents the many-to-many relationship between events and categories
class EventCategory:
    def __init__(self, eventId: str, categoryId: str):
        self.eventId = eventId        # ID of the event
        self.categoryId = categoryId  # ID of the category

    def getEventCategoryDetails(self):
        # Return string representation of the relationship
        return f"Event ID: {self.eventId}, Category ID: {self.categoryId}"
    
    
    
    


# Exra Rahaf Notes
#I moved "registerStudent" and "unregisterStudent" methods from User class to Event class  
# I added a "categoryIdlist" to store multiple categories "self.categoryIdList: List[str] = []"" 


