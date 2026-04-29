from sqlalchemy import Column, Computed, Index, BigInteger, String, Text
from sqlalchemy.orm import declarative_base
from sqlalchemy.dialects.postgresql import TSVECTOR

Base = declarative_base()

class Document(Base):
    __tablename__ = 'documents'

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    title = Column(String(100),nullable=False)
    content = Column(Text, nullable=False)
    content_tsv = Column(
        TSVECTOR,
        Computed("to_tsvector('english', coalesce(title, '') || ' ' || coalesce(content, ''))", persisted=True)
    )

    __table_args__ = (
        Index(
            'idx_content_tsv', # name of the index
            'content_tsv',     # column to index
            postgresql_using='gin' # use GIN index for full-text search
        ),
    )