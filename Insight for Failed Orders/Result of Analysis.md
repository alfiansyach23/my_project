## OBJECTIVE
This project tells the story of an order failure that occurred at a company engaged in transportation, namely Taxi, called Gett. Gett, previously known as GetTaxi, is an Israeli-developed technology platform solely focused on corporate Ground Transportation Management (GTM). They have an application where clients can order taxis, and drivers can accept their rides (offers). At the moment, when the client clicks the Order button in the application, the matching system searches for the most relevant drivers and offers them the order. In this task, we would like to investigate some matching metrics for orders that did not completed successfully, i.e., the customer didn’t end up getting a car.

## RESULT OF ANALYSIS
### Build up distribution of orders according to reasons for failure: cancellations before and after driver assignment, and reasons for order rejection. Analyse the resulting plot. Which category has the highest number of orders?

![Screenshot (559)](https://github.com/alfiansyach23/my_project/assets/127624933/97463f1b-e401-4cfa-849a-58be5508eb2a)

Most of the order failures were due to drivers not being assigned, either because they were canceled by the customer or the system rejected them, totaling 298 orders with an overall percentage of 43.63%

### Plot the distribution of failed orders by hours. Is there a trend that certain hours have an abnormally high proportion of one category or another? What hours are the biggest fails? How can this be explained?

![Screenshot (562)](https://github.com/alfiansyach23/my_project/assets/127624933/8f34d4b5-e3fc-489d-b143-05f56b0ded13)

The most order failures occurred at 8 a.m. for 24 orders

### Plot the average time to cancellation with and without driver, by the hour. If there are any outliers in the data, it would be better to remove them. Can we draw any conclusions from this plot?

![Screenshot (569)](https://github.com/alfiansyach23/my_project/assets/127624933/bdd898e3-d02d-4adc-8783-cf8665a78e4b)

The average order failure based on cancel time in seconds when drivers are assigned is 274.3 seconds per order failure and unassigned is 1190.9 seconds per order failure

### Plot the distribution of Total Order by hours. How can this plot be explained?

![Screenshot (567)](https://github.com/alfiansyach23/my_project/assets/127624933/81451c84-8619-48bc-a74c-b60cdd7f3996)

The average order failure in 1 hour is 4.97 failed orders when the client does not cancel, 4.38 failed orders when the system does not reject, 2 failed orders because the client canceled, and 0.03 failed orders because the system rejected
