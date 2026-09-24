namespace TripPlanning.Api.Exceptions
{
    public class SavedTripQuotaExceededException : Exception
    {
        public SavedTripQuotaExceededException()
            : base("Saved trips limit reached.")
        {
        }
    }
}