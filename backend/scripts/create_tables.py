from app.db.session import engine
from app.models.chat import Base
Base.metadata.create_all(bind=engine)
print("Tables created.")
