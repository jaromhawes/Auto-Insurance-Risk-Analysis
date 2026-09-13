# Auto Insurance Claims Risk Analysis

A short actuarial-style analysis of a private passenger auto insurance portfolio, examining how claim frequency and claim severity vary across key rating variables (driver age, vehicle age, and geographic area), and combining them into a pure premium view to identify the most meaningful risk signals.

📄 **[Read the full memo](output/Auto_Insurance_Risk_Memo.pdf)**

## Summary

Using a portfolio of 67,856 one-year auto policies, this project decomposes loss cost into frequency and severity — the standard actuarial ratemaking approach — and finds:

- Driver age is the dominant risk signal. The youngest driver category has a pure premium **71% above** the portfolio average; the oldest categories run **25–30% below** average.
- Vehicle age behaves counter-intuitively. Claim frequency actually decreases slightly as vehicles age, while average severity trends upward — a reminder that rating factors should be built from data, not assumption.
- Geography is a real but thinner signal, and the highest-frequency zone also has the smallest exposure base, flagging it as a candidate for credibility weighting rather than full-weight use.

## Data

This project uses the **`dataCar`** dataset — 67,856 one-year auto insurance policies written in Australia in 2004–2005, with a 6.8% claim rate. It originates from Piet de Jong and Gillian Heller's textbook *Generalized Linear Models for Insurance Data* (Cambridge University Press, 2008), distributed via the R `insuranceData` package, and pulled here as a plain CSV via the [Rdatasets](https://github.com/vincentarelbundock/Rdatasets) mirror.

| Field | Description |
|---|---|
| `veh_value` | Vehicle value ($10,000s) |
| `exposure` | Policy exposure (fraction of a year, 0–1) |
| `clm` | Claim occurred (0/1) |
| `numclaims` | Number of claims |
| `claimcst0` | Total claim cost (0 if no claim) |
| `veh_body`, `veh_age` | Vehicle body type and age category |
| `gender`, `agecat` | Driver gender and age category |
| `area` | Geographic area (A–F) |

## Methodology

1. Frequency = claims ÷ exposure (claims per policy-year)
2. Severity = average cost per claim, conditional on a claim occurring
3. Pure premium = frequency × severity = expected loss per exposure-year
4. Relativities were computed by rating variable, indexed to the portfolio average (1.0), following the standard framing used in ratemaking work.

## Repo structure

```
├── data/
│   └── dataCar.csv              # raw dataset
├── analysis.R                   # full R script: summaries, tables, and charts
├── output/
│   ├── Auto_Insurance_Risk_Memo.pdf   # final writeup
│   ├── age_summary.csv                # frequency/severity by driver age
│   ├── vehage_summary.csv             # frequency/severity by vehicle age
│   ├── area_summary.csv               # frequency/severity by area
│   └── plots/                         # all generated charts (PNG)
└── README.md
```

## Run it yourself

```r
# from the repo root
Rscript analysis.R
```

Requires base R only — no external packages needed.

## Limitations

- These are univariate relativities; a full ratemaking exercise would fit a multivariate GLM (e.g., Poisson for frequency, Gamma for severity) to isolate each factor's independent effect.
- The area-level severity finding rests on a thinner slice of exposure and would benefit from a credibility-weighted estimate.
- Data reflects a single historical period (2004–05) in one market; relativities would need refreshing against current experience before any real pricing use.
