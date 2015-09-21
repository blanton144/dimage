import unittest
import os
import dimage.path

class TestPathsFake(unittest.TestCase):

  def setUp(self):
      try:
          self.oldfake= os.environ['FAKEPHOTOMETRY']
      except:
          pass
      self.dpath= dimage.path()
      os.environ['FAKEPHOTOMETRY']='/fake'

  def tearDown(self):
      try:
          os.environ['FAKEPHOTOMETRY']=self.oldfake
      except:
          pass
  
  def test_fake_model_list(self):
      path= self.dpath.full('model-list', take='take', model='model')
      self.assertEqual(path, '/fake/take/models/model/model-model-list.fits')
      
  def test_fake_model_params(self):
      path= self.dpath.full('model-params', take='take', model='model')
      self.assertEqual(path, '/fake/take/models/model/model-model-params.fits')
      
  def test_fake_model_fits(self):
      path= self.dpath.full('model-png', take='take', model='model', index=0)
      self.assertEqual(path, '/fake/take/models/model/png/model-model-0.png')
      
  def test_fake_model_png(self):
      path= self.dpath.full('model-png', take='take', model='model', index=0)
      self.assertEqual(path, '/fake/take/models/model/png/model-model-0.png')
      
class TestPathsAtlas(unittest.TestCase):
    
    def setUp(self):
        try:
            self.oldatlas= os.environ['ATLAS_DATA']
        except:
            pass
        self.dpath= dimage.path()
        os.environ['ATLAS_DATA']='/atlas'

    def tearDown(self):
        try:
            os.environ['ATLAS_DATA']=self.oldatlas
        except:
            pass

    def test_atlas(self):
        path= self.dpath.full('atlas', version='v1_0_0')
        self.assertEqual(path, '/atlas/v1/catalogs/atlas.fits')

    def test_atlas_source(self):
        path= self.dpath.full('atlas_source', version='v1_0_0', source='source')
        self.assertEqual(path, '/atlas/v1/catalogs/source_atlas.fits')

    def test_atlas_iminfo(self):
        path= self.dpath.full('atlas_iminfo', version='v1_0_0')
        self.assertEqual(path, '/atlas/v1/catalogs/atlas_iminfo.fits')

    def test_atlas_pcat_iauname(self):
        path= self.dpath.full('pcat', version='v1_0_0', iauname='J000000.00+000000.0')
        self.assertEqual(path, '/atlas/v1/detect/v1_0/00h/p00/J000000.00+000000.0/J000000.00+000000.0-pcat.fits.gz')

    def test_atlas_pcat_nsaid(self):
        path= self.dpath.full('pcat', version='v1_0_0', nsaid=10)
        self.assertEqual(path, '/atlas/v1/detect/v1_0/00h/p00/J000000.00+000000.0/J000000.00+000000.0-pcat.fits.gz')
        

    
