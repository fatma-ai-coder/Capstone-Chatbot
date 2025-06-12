from flask import Flask, request, jsonify, session, send_from_directory
from rag_module import ChatBot
import yaml
from flask_cors import CORS
import logging
import uuid
import json
import os

logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

app = Flask(__name__)
app.secret_key = 'dar_al_hekma_secret_key'  # Necesario para manejar sesiones
CORS(app)

def load_config():
    """Load configuration from YAML file."""
    try:
        with open("config.yaml", 'r') as file:
            return yaml.safe_load(file)
    except Exception as e:
        logger.error(f"Error loading config file: {str(e)}")
        raise

try:
    chatbot = ChatBot("config.yaml")
    config = load_config()
    logger.info("Successfully initialized chatbot and loaded config")
except Exception as e:
    logger.error(f"Failed to initialize chatbot: {str(e)}")
    raise

@app.route('/chat', methods=['POST'])
def chat():
    """Handle chat requests."""
    try:
        logger.debug("Received chat request")
        data = request.get_json()
        logger.debug(f"Request data: {data}")
        
        if not data or 'message' not in data:
            logger.warning("Invalid request: message is missing")
            return jsonify({'error': 'Message is required'}), 400
            
        user_input = data['message']
        
        # Get or generate session ID
        session_id = data.get('session_id')
        if not session_id:
            # If no session_id provided, generate a new one
            session_id = str(uuid.uuid4())
            logger.debug(f"Generated new session ID: {session_id}")
        else:
            logger.debug(f"Using provided session ID: {session_id}")
        
        k = data.get('k', config.get('retrieval_k', 5))
        score_threshold = data.get('score_threshold', config.get('similarity_threshold', 0.2))
        
        logger.debug(f"Processing chat with parameters: k={k}, score_threshold={score_threshold}, session_id={session_id}")
        
        # No need to pass conversation_history as it's now managed by LangChain's memory system
        response = chatbot.chat(
            query=user_input,
            k=k,
            score_threshold=score_threshold,
            session_id=session_id
        )
        
        logger.debug("Successfully generated response")
        return jsonify({
            'response': response,
            'status': 'success',
            'session_id': session_id  # Return session_id to client
        })
        
    except Exception as e:
        logger.error(f"Error in chat endpoint: {str(e)}", exc_info=True)
        return jsonify({
            'error': str(e),
            'status': 'error'
        }), 500

@app.route('/api/events', methods=['GET'])
def get_events():
    """Serve events from JSON file."""
    try:
        logger.debug("Received request for events")
        
        # Path to events JSON file
        events_file = os.path.join('events', 'events.json')
        
        # Read and return events data
        with open(events_file, 'r') as file:
            events_data = json.load(file)
            
        logger.debug(f"Successfully retrieved {len(events_data)} events")
        return jsonify(events_data)
        
    except Exception as e:
        logger.error(f"Error serving events: {str(e)}", exc_info=True)
        return jsonify({
            'error': str(e),
            'status': 'error'
        }), 500

# Serve static files from events directory
@app.route('/api/events/images/<path:filename>')
def serve_event_image(filename):
    return send_from_directory('events/images', filename)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5555)