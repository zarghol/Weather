//
//  CAEmitterCell+Cells.swift
//  Weather
//
//  Created by Clément NONN on 31/12/2017.
//  Copyright © 2017 Clément NONN. All rights reserved.
//

import UIKit

extension CAEmitterCell {
    static var snow: CAEmitterCell {
        let cell = CAEmitterCell()
        cell.birthRate = 2.8
        cell.alphaRange = 1.0
        cell.color = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1).cgColor
        cell.lifetime = 7.0
        cell.velocity = 25
        cell.velocityRange = 5
        cell.emissionLongitude = .pi
        cell.emissionRange = .pi / 4
        cell.scale = 0.1
        cell.scaleRange = 0.1
        cell.contents = #imageLiteral(resourceName: "snowParticle").cgImage
        return cell
    }
    
    static var rain: CAEmitterCell {
        let cell = CAEmitterCell()
        cell.birthRate = 100
        cell.alphaRange = 1.0
        cell.color = #colorLiteral(red: 0.5392423272, green: 0.6809436679, blue: 1, alpha: 1).cgColor
        cell.lifetime = 0.5
        cell.velocity = 600
        cell.velocityRange = 15
        cell.emissionLongitude = .pi
        cell.scale = 0.1
        cell.contents = #imageLiteral(resourceName: "rainParticle").cgImage
        return cell
    }
    
    static var bolts: [CAEmitterCell] {
        return [(#imageLiteral(resourceName: "eclair1"), 0.2), (#imageLiteral(resourceName: "eclair2"), 0.1), (#imageLiteral(resourceName: "eclair3"), 0.15)].map {
            let cell = CAEmitterCell()
            cell.birthRate = Float($0.1)
            cell.alphaRange = 1.0
            cell.lifetime = 0.05
            cell.scale = 0.1
            cell.scaleRange = 0.3
            cell.contents = $0.0.cgImage
            return cell
        }
    }
    
    static var sun: [CAEmitterCell] {
        let mainCell = CAEmitterCell()
        mainCell.birthRate = 1
        mainCell.color = #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1).cgColor
        mainCell.lifetime = 1
        mainCell.scale = 0.45
        mainCell.contents = #imageLiteral(resourceName: "sunParticle").cgImage
        
        let haloCell = CAEmitterCell()
        haloCell.birthRate = 20
        haloCell.color = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1).withAlphaComponent(0.2).cgColor
        haloCell.lifetime = 0.2
        haloCell.scaleRange = 0.1
        haloCell.scale = 0.5
        haloCell.contents = #imageLiteral(resourceName: "sunParticle").cgImage
        return [haloCell, mainCell]
    }
    
    static var moon: CAEmitterCell {
        let mainCell = CAEmitterCell()
        mainCell.birthRate = 1
        mainCell.color = #colorLiteral(red: 0.9346919656, green: 0.9558759332, blue: 1, alpha: 1).cgColor
        mainCell.lifetime = 1
        mainCell.scale = 0.45
        mainCell.contents = #imageLiteral(resourceName: "sunParticle").cgImage
        return mainCell
    }
    
    static var stars: CAEmitterCell {
        let mainCell = CAEmitterCell()
        mainCell.birthRate = 10
        mainCell.color = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        mainCell.lifetime = 5
        mainCell.scale = 0.05
        mainCell.contents = #imageLiteral(resourceName: "snowParticle").cgImage
        return mainCell
    }
    
    static var waves: CAEmitterCell {
        let cell = CAEmitterCell()
        cell.birthRate = 7
        cell.alphaRange = 1.0
        cell.alphaSpeed = 2.0
        
        cell.color = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).withAlphaComponent(0.4).cgColor
        cell.lifetime = 3.0
        cell.velocity = 40
        cell.velocityRange = 15
        cell.emissionLongitude = .pi
        cell.emissionRange = .pi / 3.5
        cell.scale = 1.0
        
        cell.contents = #imageLiteral(resourceName: "windParticle").cgImage
        return cell
    }
    
    static var wind: CAEmitterCell {
        let cell = CAEmitterCell()
        cell.birthRate = 7
        cell.alphaRange = 0.2
        cell.color = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1).withAlphaComponent(0.2).cgColor
        cell.lifetime = 3.0
        cell.velocity = 40
        cell.velocityRange = 15
        cell.scale = 1.0
        
        cell.contents = #imageLiteral(resourceName: "windParticle").cgImage
        return cell
    }
    
    static var clouds: CAEmitterCell {
        let cell = CAEmitterCell()
        cell.birthRate = 0.7
        cell.alphaRange = 0.2
        //        cell.alphaSpeed = 2.0
        
        cell.color = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        cell.lifetime = 20.0
        cell.velocity = 40
        cell.velocityRange = 15
        //        cell.emissionLongitude = .pi
        //        cell.emissionRange = .pi / 3.5
        cell.scale = 1.0
        
        cell.contents = #imageLiteral(resourceName: "cloudParticle").cgImage
        return cell
    }
}
