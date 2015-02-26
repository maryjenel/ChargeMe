//
//  PromotionsViewController.swift
//  ChargeMe
//
//  Created by Mary Jenel Myers on 2/23/27 H.
//  Copyright (c) 27 Heisei Mary Jenel Myers. All rights reserved.
//

import UIKit
import QuartzCore


// Util delay function
//functions where actual time values can be specified rather than a number of cycles to wait for
func delay(#seconds: Double, completion:()->())
{
    let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * seconds ))

    dispatch_after(popTime, dispatch_get_main_queue())
        {
        completion()
    }
}


class PromotionsViewController: UIViewController
{
    //outlets
    @IBOutlet weak var carImageView: UIImageView!
    @IBOutlet weak var whiteCar: UIImageView!
    @IBOutlet weak var whiteCar2: UIImageView!
    @IBOutlet weak var star1: UIImageView!
    @IBOutlet weak var star3: UIImageView!
    @IBOutlet weak var star2: UIImageView!
    @IBOutlet weak var star4: UIImageView!
    @IBOutlet weak var star5: UIImageView!
    @IBOutlet weak var star6: UIImageView!
    @IBOutlet weak var star7: UIImageView!
    @IBOutlet weak var menuButton: UIBarButtonItem!





    override func viewDidLoad()
    {
        super.viewDidLoad()

        //when menu button clicked reveals the side menu
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }


    }

    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)

//call the animated cars method
    animateCars(self.carImageView)
    animateCars(self.whiteCar)
    animateCars(self.whiteCar2)
//call the blinking star method
    blinkingStar(self.star1)
    blinkingStar2(self.star2)
    blinkingStar3(self.star3)
    blinkingStar(self.star4)
    blinkingStar2(self.star5)
    blinkingStar3(self.star6)
    blinkingStar(self.star7)
    }


    //method to animate Cars
    func animateCars(car:UIImageView)
    {
        let carSpeed = 20.0 / Double(view.frame.size.width)
        let duration: NSTimeInterval = Double(view.frame.size.width - car.frame.origin.x) * carSpeed
        UIView.animateWithDuration(duration, delay: 0.0, options: .CurveLinear, animations:
            {
                car.frame.origin.x = self.view.bounds.size.width
            }, completion: {_ in
                //reset cloud
                car.frame.origin.x = -self.carImageView.frame.size.width
                self.animateCars(car)

        });
    }

//blinking star method
    func blinkingStar(star:UIImageView)
    {

        var pulseAnimation:CABasicAnimation = CABasicAnimation(keyPath: "opacity");
        //sets the blinking duration
        pulseAnimation.duration = 0.6;
        //set the opacity to 0
        pulseAnimation.toValue = NSNumber(float: 0.0);
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut);
        pulseAnimation.autoreverses = true;
        pulseAnimation.repeatCount = FLT_MAX;
        star.layer.addAnimation(pulseAnimation, forKey: nil)
    }

//blinking star method but different time
    func blinkingStar2(star:UIImageView)
    {

        var pulseAnimation:CABasicAnimation = CABasicAnimation(keyPath: "opacity");
        //sets the blinking duration
        pulseAnimation.duration = 0.8;
        //set the opacity to 0
        pulseAnimation.toValue = NSNumber(float: 0.0);
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut);
        pulseAnimation.autoreverses = true;
        pulseAnimation.repeatCount = FLT_MAX;
        star.layer.addAnimation(pulseAnimation, forKey: nil)
    }

// blink star method but slower
    func blinkingStar3(star:UIImageView)
    {

        var pulseAnimation:CABasicAnimation = CABasicAnimation(keyPath: "opacity");
        //sets the blinking duration
        pulseAnimation.duration = 1.0;
        //set the opacity to 0
        pulseAnimation.toValue = NSNumber(float: 0.0);
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut);
        pulseAnimation.autoreverses = true;
        pulseAnimation.repeatCount = FLT_MAX;
        star.layer.addAnimation(pulseAnimation, forKey: nil)
    }
}








