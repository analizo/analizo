from horse import Horse
from flying import Flying

class Pegasus(Horse, Flying):
    def fly(self):
        print("i'm flying!")