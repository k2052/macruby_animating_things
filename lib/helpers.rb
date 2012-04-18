def degreesToRadian(num)   
  return num / 57.29578
end  

def rotateAnimation(from, to, keyPath='transform.rotation.x')
  animation = CABasicAnimation.animationWithKeyPath(keyPath)
 
  animation.setFromValue(from)
  animation.setToValue(to)
  
  animation.setRemovedOnCompletion(false)
  animation.setFillMode(KCAFillModeForwards)
  
  return animation
end