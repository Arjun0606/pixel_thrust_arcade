import SwiftUI
import StoreKit

struct ShopView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var storeManager = StoreManager.shared
    @State private var selectedCategory: IAPCategory = .bundles
    @State private var todaysDeals: [DailyDeal] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Premium gradient
                LinearGradient(
                    colors: [Color(red: 0.95, green: 0.85, blue: 0.95), Color(red: 0.85, green: 0.75, blue: 0.95)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Pro Status Banner
                        if storeManager.isPro {
                            ProBanner()
                        }
                        
                        // Daily Deals Section
                        if !todaysDeals.isEmpty {
                            DailyDealsSection(deals: todaysDeals)
                        }
                        
                        // Category Selector
                        CategoryPicker(selected: $selectedCategory)
                        
                        // Products Grid
                        ProductsGrid(category: selectedCategory)
                    }
                    .padding()
                }
            }
            .navigationTitle("Shop")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .onAppear {
            todaysDeals = DailyDealsManager.shared.getTodaysDeals()
        }
    }
}

struct ProBanner: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.title)
                .foregroundStyle(.yellow)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Pro Member")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                Text("50% off all purchases!")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.yellow.opacity(0.2), Color.orange.opacity(0.2)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.yellow.opacity(0.5), lineWidth: 2)
        )
    }
}

struct DailyDealsSection: View {
    let deals: [DailyDeal]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundStyle(.orange)
                Text("Daily Deals")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                Spacer()
                Text("24h")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.red)
                    .cornerRadius(8)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(Array(deals.enumerated()), id: \.offset) { _, deal in
                        DealCard(deal: deal)
                    }
                }
            }
        }
    }
}

struct DealCard: View {
    let deal: DailyDeal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("-\(Int(deal.discount * 100))%")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.red)
                    .cornerRadius(8)
                Spacer()
            }
            
            Text(deal.product.displayName)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
            
            Text(deal.product.description)
                .font(.system(size: 12, design: .rounded))
                .foregroundStyle(.secondary)
                .lineLimit(2)
            
            HStack {
                Text("$\(String(format: "%.2f", deal.discountedPrice))")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.green)
                
                Text("$\(String(format: "%.2f", deal.product.basePrice))")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(.secondary)
                    .strikethrough()
            }
            
            Button("Buy Now") {
                // Purchase logic
            }
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                LinearGradient(
                    colors: [.purple, .pink],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
        }
        .padding()
        .frame(width: 200)
        .background(.white.opacity(0.9))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
    }
}

struct CategoryPicker: View {
    @Binding var selected: IAPCategory
    
    let categories: [IAPCategory] = [.bundles, .currency, .convenience, .cosmetics, .energy]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    Button(action: { selected = category }) {
                        Text(category.rawValue)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(selected == category ? .white : .primary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                selected == category ?
                                LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing) :
                                LinearGradient(colors: [.white.opacity(0.7)], startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(20)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct ProductsGrid: View {
    let category: IAPCategory
    
    var products: [IAPProduct] {
        IAPProduct.allCases.filter { $0.category == category }
    }
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(products, id: \.self) { product in
                ProductCard(product: product)
            }
        }
    }
}

struct ProductCard: View {
    let product: IAPProduct
    @StateObject private var storeManager = StoreManager.shared
    
    var effectivePrice: Double {
        storeManager.isPro ? product.proPrice : product.basePrice
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if storeManager.isPro && product.category != .subscription {
                HStack {
                    Text("50% OFF")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green)
                        .cornerRadius(6)
                    Spacer()
                }
            }
            
            Text(product.displayName)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
            
            Text(product.description)
                .font(.system(size: 12, design: .rounded))
                .foregroundStyle(.secondary)
                .lineLimit(2)
            
            Spacer()
            
            HStack {
                Text("$\(String(format: "%.2f", effectivePrice))")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                
                if storeManager.isPro && product.category != .subscription {
                    Text("$\(String(format: "%.2f", product.basePrice))")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(.secondary)
                        .strikethrough()
                }
            }
            
            Button("Purchase") {
                // Purchase logic
            }
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(Color.purple)
            .cornerRadius(12)
        }
        .padding()
        .background(.white.opacity(0.9))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
    }
}
