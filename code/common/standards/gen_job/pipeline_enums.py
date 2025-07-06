from enum import Enum, auto


class PipelineType(str, Enum):
    INGESTION: str = auto()
    TRANSFORMATION: str = auto()


class PipelineVelocity(str, Enum):
    BATCH: str = auto()
    STREAM: str = auto()
