import unittest
from pyxi.x88 import Tumbler


class TestTumbler(unittest.TestCase):
    def test_add(self):        
        t1 = Tumbler(0, 0, 0)
        t2 = Tumbler(0, 5, 0)
        t3 = Tumbler(1, 4, 3)
        t4 = Tumbler(1, 0, 0, 1, 0, 3, 0, 5, 0, 21, 0)
        t5 = Tumbler(4, 5, 0, 1, 4, 1, 0, 7, 0, 2, 3)
    
        for t, rt in [(t1+t2, '0.5.0'), 
                (t3+t4, '2.0.0.1.0.3.0.5.0.21.0'),
                (t2+t3, '1.4.3'), 
                (t4+t5, '5.5.0.1.4.1.0.7.0.2.3')]:
            self.assertEqual(str(t), rt)               
        print t3
        print t4
        print t3+t4
                            

if __name__ == '__main__': unittest.main()        
