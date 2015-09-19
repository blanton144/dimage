import unittest
import os
from dimage.atlas import atlas_path

class TestPathsFake(unittest.TestCase):

  def setUp(self):
      self.oldfake= os.environ['FAKEPHOTOMETRY']
      self.apath= atlas_path()
      os.environ['FAKEPHOTOMETRY']='/fake'

  def tearDown(self):
      os.environ['FAKEPHOTOMETRY']=self.oldfake
  
  def test_fake_model_list(self):
      path= self.apath.full('model-list', take='take', model='model')
      self.assertEqual(path, '/fake/take/models/model/model-model-list.fits')
      
  def test_fake_model_params(self):
      path= self.apath.full('model-params', take='take', model='model')
      self.assertEqual(path, '/fake/take/models/model/model-model-params.fits')
      
  def test_fake_model_fits(self):
      path= self.apath.full('model-png', take='take', model='model', index=0)
      self.assertEqual(path, '/fake/take/models/model/png/model-model-0.png')
      
  def test_fake_model_png(self):
      path= self.apath.full('model-png', take='take', model='model', index=0)
      self.assertEqual(path, '/fake/take/models/model/png/model-model-0.png')
      
class TestPathsAtlas(unittest.TestCase):
    
    def setUp(self):
        self.oldatlas= os.environ['ATLAS_DATA']
        self.apath= atlas_path()
        os.environ['ATLAS_DATA']='/atlas'

    def tearDown(self):
        os.environ['ATLAS_DATA']=self.oldatlas

    def test_atlas(self):
        path= self.apath.full('atlas', version='v1_0_0')
        self.assertEqual(path, '/atlas/v1/catalogs/atlas.fits')

    def test_atlas_source(self):
        path= self.apath.full('atlas', version='v1_0_0', source='source')
        self.assertEqual(path, '/atlas/v1/catalogs/source_atlas.fits')

    def test_atlas_iminfo(self):
        path= self.apath.full('atlas', version='v1_0_0')
        self.assertEqual(path, '/atlas/v1/catalogs/atlas_iminfo.fits')
        

    
