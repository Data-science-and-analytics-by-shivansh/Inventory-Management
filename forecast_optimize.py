import pandas as pd
from prophet import Prophet
from pulp import LpMinimize, LpProblem, LpVariable, lpSum, value

df = pd.read_csv('data/inventory_data.csv', parse_dates=['Date'])
df = df[df['SalesQuantity'] > 0]

# Demand Forecasting per Product (example for one SKU)
sku = df['ProductID'].unique()[0]
sku_df = df[df['ProductID'] == sku][['Date', 'SalesQuantity']].rename(columns={'Date': 'ds', 'SalesQuantity': 'y'})
model = Prophet()
model.fit(sku_df)
future = model.make_future_dataframe(periods=30)
forecast = model.predict(future)
forecast[['ds', 'yhat']].to_csv('outputs/forecast.csv', index=False)

# Simple EOQ Optimization (Economic Order Quantity)
# EOQ = sqrt(2DS/H), D=demand, S=setup cost, H=holding cost
annual_demand = df.groupby('ProductID')['SalesQuantity'].sum()
setup_cost = 50  # assumed per order
holding_cost = 2  # per unit per year
eoq = {}
for sku, D in annual_demand.items():
    eoq[sku] = (2 * D * setup_cost / holding_cost) ** 0.5

print("EOQ Recommendations:", eoq)

# PuLP Replenishment Optimization (min cost subject to demand)
# Simplified: allocate orders under budget
prob = LpProblem("Replenishment", LpMinimize)
products = df['ProductID'].unique()[:10]  # sample
order_qty = {p: LpVariable(f"order_{p}", lowBound=0) for p in products}
cost = {p: df[df['ProductID']==p]['UnitCost'].mean() for p in products}

prob += lpSum([cost[p] * order_qty[p] for p in products])  # min cost
prob += lpSum([order_qty[p] for p in products]) >= 1000  # meet min demand

prob.solve()
print("Optimized Order Quantities:")
for p in products:
    print(f"{p}: {value(order_qty[p])}")
