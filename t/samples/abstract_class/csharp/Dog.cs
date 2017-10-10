class Dog : FourLeggedAnimal
{
    public override string Describe()
    {
        string result = base.Describe();
        result += " In fact, it's a dog!";
        return result;
    }
}