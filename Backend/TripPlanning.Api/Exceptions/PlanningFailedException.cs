namespace TripPlanning.Api.Exceptions
{
    public class PlanningFailedException : Exception
    {
        public PlanningFailedException(
            string message,
            Exception? innerException = null)
            : base(message, innerException)
        {
        }
    }
}