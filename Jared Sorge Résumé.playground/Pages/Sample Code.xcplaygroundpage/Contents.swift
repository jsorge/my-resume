//: [Previous](@previous)

import UIKit
import PlaygroundSupport

/*:
 # Sample Code
 
 Here you can find some code that I wrote earlier this year to display a carousel of pageable views. The thing I really like about how it has turned out is that the API is approachable to get going, yet there are lots of customizations to get just the presentation that you want. Be sure to look at the CarouselView.swift file inside this playground's Sources folder
 */

class HeroVC: UIViewController {
    lazy var carouselView: CarouselView = {
        let carousel = CarouselView()
            view.addSubview(carousel)
        carousel.translatesAutoresizingMaskIntoConstraints = false
        carousel.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        carousel.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        carousel.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        carousel.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        // Toggle commenting out the following lines before the return to see some of the flexibility of the carousel
        carousel.isInifiniteScrolling = true
        carousel.inactiveTileConfig = .dim(0.5)
        carousel.horizontalPadding = 4.0
        
        return carousel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let tileWidth = size.width * 0.9
        let tileHeight = size.height * 0.6
        carouselView.tileSize = CGSize(width: tileWidth, height: tileHeight)
    }
    
    func updateCarouselWithImages(_ ourHeroes: [HeroTile]) {
        carouselView.display(ourHeroes)
    }
}

struct HeroTile: CarouselTile {
    let heroImage: UIImage
    
    func generateView() -> UIView {
        let imageView = UIImageView(image: heroImage)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
}

let vc = HeroVC()
PlaygroundPage.current.liveView = vc

let batman = HeroTile(heroImage: #imageLiteral(resourceName: "Batman.jpeg"))
let flash = HeroTile(heroImage: #imageLiteral(resourceName: "Flash.jpeg"))
let gambit = HeroTile(heroImage: #imageLiteral(resourceName: "Gambit.jpeg"))
let spidey = HeroTile(heroImage: #imageLiteral(resourceName: "Spiderman.jpeg"))
let supes = HeroTile(heroImage: #imageLiteral(resourceName: "Superman.jpeg"))
let logan = HeroTile(heroImage: #imageLiteral(resourceName: "Wolverine.jpeg"))
vc.updateCarouselWithImages([batman, flash, gambit, spidey, supes, logan])


//: [Next](@next)
