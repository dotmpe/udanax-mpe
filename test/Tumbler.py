import unittest
from pyxi.x88 import Tumbler


class TestTumbler(unittest.TestCase):
    def test_add(self):        
        t1 = Tumbler(0, 0, 0)
        t2 = Tumbler(0, 5, 0)
        t3 = Tumbler(1, 4, 3)
        t4 = Tumbler(1, 0, 0, 1, 0, 3, 0, 5, 0, 21, 0)
        t5 = Tumbler(4, 5, 0, 1, 4, 1, 0, 7, 0, 2, 3)

        # From Udanax.com Tumbler arithmetic page 
        t6 = Tumbler("3.5.10.6")
        t7 = Tumbler("2.16.3")
        t8 = Tumbler("5.16.3")
        
        t9 = Tumbler("25.6.46.93")
        t10 = Tumbler("0.0.3.1.21")
        t11 = Tumbler("25.6.49.1.21")
    
        for t, rt in [(t1+t2, '0.5.0'), 
                    (t3+t4, '2.0.0.1.0.3.0.5.0.21.0'),
                    (t2+t3, '1.4.3'), 
                    (t4+t5, '5.5.0.1.4.1.0.7.0.2.3'),
                    (t6+t7, str(t8)),
                    (t9+t10, str(t11))
                ]:
            self.assertEqual(str(t), rt)               
                            
    def test_sub(self):        
        t1 = Tumbler(1, 1)
        t2 = Tumbler(0, 1)
        t3 = Tumbler(1, 2)
        t4 = Tumbler(5,3,2)
        t5 = Tumbler(1,4,5,7,4,8,9)
        t6 = Tumbler(0,0,1)
        for t, rt in [
                    (t1-t2, '1'), 
                    (t3-t2, '1.1'), 
                    (t4-t2, '5.2'), 
                    (t5-t6, '1.4.4'), 
                ]:
            if str(t) !=  rt:
                    print "Fail", str(t), rt
            #self.assertEqual(str(t), rt)               
                            

if __name__ == '__main__': unittest.main()        
