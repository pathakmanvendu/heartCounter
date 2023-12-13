//
//  ContentView.swift
//  heartCounter Watch App
//
//  Created by Manvendu Pathak on 06/10/23.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    @State private var animationAmount: CGFloat = 1
    private var healthStore = HKHealthStore()
    let heartRateQuantity = HKUnit(from: "count/min")
    @State var random = Int.random(in: 75...100)
    @State private var value = 0
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var body: some View {
        VStack{
                 HStack{
                     Image(systemName: "heart.fill")
                         .resizable()
                                   .frame(width: 50, height: 50)
                                   .foregroundColor(.red)
                                   .scaleEffect(animationAmount)
                                   .animation(
                                       .spring(response: 0.2, dampingFraction: 0.3, blendDuration: 0.8) // Change this line
                                       .delay(0.2)
                                           .repeatForever(autoreverses: true),
                                       value: animationAmount)
                                   .onAppear {
                                       animationAmount = 1.2
                                   }
                        
                     

                 }
                 
                 HStack{
                     Text("\(random)")
                         .onReceive(timer){_ in
                             random+=1
                             
                         }
                         .fontWeight(.regular)
                         .font(.system(size: 70))
                     
                     Text("BPM")
                         .font(.headline)
                         .fontWeight(.bold)
                         .foregroundColor(Color.red)
                         .padding(.bottom, 28.0)
                     
                     Spacer()
                     
                 }

             }
             .padding()
             .onAppear(perform: start)
             
    }
    
    func start() {
        authorizeHealthKit()
        
    }
    
    
    
    func authorizeHealthKit() {
        let healthKitType: Set = [
            
        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!]
        healthStore.requestAuthorization(toShare: healthKitType, read: healthKitType) { _, _ in}
        
    }
    
    private func startHealthRateQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier) {
        let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
        let updateHandler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = {
            query, samples, deletedObjects, queryAnchor, error in
            
            // 3
            guard let samples = samples as? [HKQuantitySample] else {
                return
            }
            self.process(samples, type: quantityTypeIdentifier)
            
        }
            let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!, predicate: devicePredicate, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: updateHandler)
            
            query.updateHandler = updateHandler
            healthStore.execute(query)
    }
    
    private func process(_ samples: [HKQuantitySample], type: HKQuantityTypeIdentifier) {
          var lastHeartRate = 0.0
          
          for sample in samples {
              if type == .heartRate {
                  lastHeartRate = sample.quantity.doubleValue(for: heartRateQuantity)
              }
              
              self.value = Int(lastHeartRate)
          }
      }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
