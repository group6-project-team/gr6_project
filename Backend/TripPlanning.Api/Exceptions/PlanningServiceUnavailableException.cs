namespace TripPlanning.Api.Exceptions
{
    public class PlanningServiceUnavailableException : Exception
    {
        public PlanningServiceUnavailableException(
            string message,
            Exception? innerException = null)
            : base(message, innerException)
        {
        }
    }
}