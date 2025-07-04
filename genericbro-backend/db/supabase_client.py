"""
Supabase client configuration and initialization.
This module provides a shared Supabase client instance for database operations.
"""

import os
from typing import Optional
from dotenv import load_dotenv
from supabase import create_client, Client, ClientOptions
from functools import lru_cache
import logging
import traceback

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class SupabaseConnectionError(Exception):
    """Custom exception for Supabase connection errors."""
    pass

@lru_cache()
def get_supabase_client() -> Client:
    """
    Creates and returns a cached Supabase client instance.
    The client is cached to avoid creating multiple connections.
    
    Returns:
        Client: A configured Supabase client instance
        
    Raises:
        SupabaseConnectionError: If environment variables are missing or connection fails
    """
    # Load environment variables from .env file
    load_dotenv()
    logger.info("Loading environment variables...")
    
    # Get Supabase credentials
    supabase_url: Optional[str] = os.getenv("SUPABASE_URL")
    supabase_key: Optional[str] = os.getenv("SUPABASE_KEY")
    
    # Validate environment variables
    if not supabase_url or not supabase_key:
        missing_vars = []
        if not supabase_url:
            missing_vars.append("SUPABASE_URL")
        if not supabase_key:
            missing_vars.append("SUPABASE_KEY")
        error_msg = f"Missing required environment variables: {', '.join(missing_vars)}"
        logger.error(error_msg)
        raise SupabaseConnectionError(error_msg)
    
    try:
        logger.info("Initializing Supabase client...")
        # Initialize Supabase client with basic options
        options = ClientOptions(schema='public')
        
        # Initialize Supabase client
        client = create_client(supabase_url, supabase_key, options=options)
        
        # Test connection by making a simple query
        logger.info("Testing database connection...")
        test_response = client.table('generic medicines list').select("Name").limit(1).execute()
        if not test_response:
            raise SupabaseConnectionError("Failed to execute test query")
        
        logger.info("Successfully connected to Supabase")
        return client
        
    except Exception as e:
        error_msg = f"Failed to initialize Supabase client: {str(e)}"
        logger.error(error_msg)
        logger.error(traceback.format_exc())
        raise SupabaseConnectionError(error_msg)

# Create a shared client instance
try:
    logger.info("Creating shared Supabase client instance...")
    supabase: Client = get_supabase_client()
    logger.info("Shared Supabase client instance created successfully")
except SupabaseConnectionError as e:
    logger.error(f"Critical error initializing Supabase client: {str(e)}")
    logger.error(traceback.format_exc())
    raise

# Export the client as the main interface
__all__ = ["supabase", "SupabaseConnectionError"] 