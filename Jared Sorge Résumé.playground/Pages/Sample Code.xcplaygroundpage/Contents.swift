/*:
 [Previous](@previous)
 
 # Sample Code
 
 Here you can find some code that I wrote in 2017 to display a _carouselView of pageable views. The thing I really like about how it has turned out is that the API is approachable to get going, yet there are lots of customizations to get just the presentation that you want. Be sure to look at the CarouselView.swift file inside this playground's Sources folder
 */

import UIKit
import PlaygroundSupport

class HeroViewController: UIViewController {
    private let _carouselView: CarouselView = {
        let carousel = CarouselView()

        // Toggle commenting out the following lines to see some of the flexibility of the carousel
        carousel.isInifiniteScrolling = true
        carousel.inactiveTileConfig = .dim(0.5)
        carousel.horizontalPadding = 4.0

        return carousel
    }()

    //MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray

        view.addSubview(_carouselView)
        _carouselView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            _carouselView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            _carouselView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            _carouselView.topAnchor.constraint(equalTo: view.topAnchor),
            _carouselView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])

        _carouselView.tileSize = CGSize(width: 300.0, height: 300.0)
    }
    
    //MARK: - API
    func updateCarouselWithImages(_ ourHeroes: [HeroTile]) {
        _carouselView.display(ourHeroes)
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

let vc = HeroViewController()
PlaygroundPage.current.liveView = vc

let batman = HeroTile(heroImage: #imageLiteral(resourceName: "Batman.jpeg"))
let flash = HeroTile(heroImage: #imageLiteral(resourceName: "Flash.jpeg"))
let gambit = HeroTile(heroImage: #imageLiteral(resourceName: "Gambit.jpeg"))
let spidey = HeroTile(heroImage: #imageLiteral(resourceName: "Spiderman.jpeg"))
let supes = HeroTile(heroImage: #imageLiteral(resourceName: "Superman.jpeg"))
let logan = HeroTile(heroImage: #imageLiteral(resourceName: "Wolverine.jpeg"))
vc.updateCarouselWithImages([batman, flash, gambit, spidey, supes, logan])


//: [Next](@next)
