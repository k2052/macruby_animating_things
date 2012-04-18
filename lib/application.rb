require 'rubygems' # disable this for a deployed application
require 'hotcocoa'  
 
# Load Windows     
Dir.glob("lib/*.rb").each do |file|
  require file
end    

class Demo
  include HotCocoa

  def start          
    application name: 'Demo' do |app| 
      app.delegate = self     
      
      @main_window = window(:frame => [100, 100, 600, 500], :title => "HotCocoa Demo Application") do |win|
        win.will_close { exit }    
                                                             
        imageRef = layerForImage()
        CFRetain(imageRef)     
        readyLayer = CALayer.alloc.init()
        readyLayer.contents = imageRef 
        readyLayer.constraints = [CAConstraint.constraintWithAttribute(KCAConstraintMidX, relativeTo:"superlayer", 
          attribute:KCAConstraintMidX), 
          CAConstraint.constraintWithAttribute(KCAConstraintMidY, relativeTo:"superlayer", attribute:KCAConstraintMidY),
          nil]   
        
        readyLayer.setFrame([0,0, image.size.width, image.size.height])
        readyLayer.setOpacity(1.0) 
        angleY = (45 / 180.0)
        angleX = (75 / 180.0) 
        
        layerTransform       = CATransform3DIdentity
        layerTransform.m34   = 1.0 / -500  
        layerTransform  = CATransform3DRotate(layerTransform, angleY, 0.0, 1.0, 0.0)
        readyLayer.transform = layerTransform 
                       
        xTransform  = CATransform3DMakeRotation(angleX, 1.0, 0.0, 0.0)
        xTransform  = CATransform3DRotate(xTransform, angleY, 0.0, 1.0, 0.0)
        readyLayer.transform = xTransform   
                
        win.contentView.setWantsLayer(true)
        win.contentView.layer.addSublayer(readyLayer)   
        readyLayer.addAnimation(rotateAnimation(0, 0.8), forKey:"rotate")
      end          
    end
  end    
  
  def layerForImage()
    image = NSImage.alloc.initWithContentsOfFile(File.join(NSBundle.mainBundle.resourcePath(),'/Images/Photo.jpg'))
    aLayerRect = NSMakeRect(0.0, 0.0, image.size.width, image.size.height)     

    # Apparently the containter constraint is need for ZPosition to work right. 
    # Setting ZPositon on the holding layer is a bad idea. At least thats what I think.
    # Might be some unccessary layers here though.

  	containerLayer = CALayer.layer
  	containerLayer.bounds        = @main_window.window.frame
  	containerLayer.layoutManager = CAConstraintLayoutManager.layoutManager()
    containerLayer.constraints   = NSArray.arrayWithObjects(CAConstraint.constraintWithAttribute(KCAConstraintMidX,
                                                               relativeTo:"superlayer", 
                                                                attribute:KCAConstraintMidX), 
                                    CAConstraint.constraintWithAttribute(KCAConstraintMidY,
                                                               relativeTo:"superlayer", 
                                                                attribute:KCAConstraintMidY),
                                    nil)

  	holderLayer = CALayer.layer
  	holderLayer.bounds        = aLayerRect
  	holderLayer.layoutManager = CAConstraintLayoutManager.layoutManager()
  	holderLayer.constraints   = NSArray.arrayWithObjects(CAConstraint.constraintWithAttribute(KCAConstraintMidX,
  														  relativeTo:"superlayer", 
  														   attribute:KCAConstraintMidX), 
  							   CAConstraint.constraintWithAttribute(KCAConstraintMidY, 
  														  relativeTo:"superlayer",
  														   attribute:KCAConstraintMidY),
  							   nil)


  	imageLayer = CALayer.layer
  	imageLayer.bounds           = aLayerRect
  	imageLayer.contentsGravity  = KCAGravityResizeAspectFill
    imageLayer.contents         = image.CGImageForProposedRect(aLayerRect, context:NSGraphicsContext.currentContext, hints:nil)
    imageLayer.constraints      = NSArray.arrayWithObjects(CAConstraint.constraintWithAttribute(KCAConstraintMidX,
                                                         relativeTo:"superlayer", 
                                                            attribute:KCAConstraintMidX), 
                                   CAConstraint.constraintWithAttribute(KCAConstraintMidY, 
                                                           relativeTo:"superlayer",
                                                            attribute:KCAConstraintMidY),
                                nil)


  	containerLayer.setValue(imageLayer, forKey:"__imageLayer")
  	containerLayer.setValue(holderLayer, forKey:"__holderLayer")

  	containerLayer.setValue(NSNumber.numberWithFloat(0.0), forKey:"__angleX")
    containerLayer.setValue(NSNumber.numberWithFloat(0.0), forKey:"__angleY")

  	holderLayer.addSublayer(imageLayer)
    containerLayer.addSublayer(holderLayer)

  	return containerLayer
  end
end

Demo.new.start