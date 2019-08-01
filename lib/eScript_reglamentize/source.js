var oApp:Application = TheApplication();

var sToType:chars = Inputs.GetProperty("To Type");//Тип получателя (Position/Employee/Direct)
var sToId:chars = Inputs.GetProperty("To Id");
var sTo = "";

var oPostnBO:BusObject = oApp.GetBusObject("Position");
var oPostnBC:BusComp = oPostnBO.GetBusComp("Position");

var oEmpBO:BusObject = oApp.GetBusObject("Employee");
var oEmpBC:BusComp = oEmpBO.GetBusComp("Employee");
	
switch(sToType)
{
	//Отсылаем письмо основному сотруднику на позиции
	case "Position":
	{
		with(oPostnBC)
		{
			ClearToQuery();
			ActivateField("Primary Employee Id");
			SetViewMode(AllView);
			SetSearchSpec("Id", sToId);
			ExecuteQuery(ForwardOnly);

			if(FirstRecord())
			{
				if(GetFieldValue("Primary Employee Id") != "")
				{
					with(oEmpBC)
					{
						ClearToQuery();
						ActivateField("EMail Addr");
						SetViewMode(AllView);
						SetSearchSpec("Id", oPostnBC.GetFieldValue("Primary Employee Id"));
						ExecuteQuery(ForwardOnly);

						if(FirstRecord())
						{
							if(GetFieldValue("EMail Addr") != "")
							{
								sTo = GetFieldValue("EMail Addr");
							}
							else
							{
								Outputs.SetProperty("Result", "ERROR");
								Outputs.SetProperty("Result Info", "Email Not Specified for Employee");
							}
						}
						else
						{
							Outputs.SetProperty("Result", "ERROR");
							Outputs.SetProperty("Result Info", "Position Not Found");
						}
					}
				}
				else
				{
					Outputs.SetProperty("Result", "ERROR");
					Outputs.SetProperty("Result Info", "No Primary Employee");
				}
			}
			else
			{
				Outputs.SetProperty("Result", "ERROR");
				Outputs.SetProperty("Result Info", "Position Not Found");
			}
		}
		break;
	}
	//Шлем письмо сотруднику напрямую
	case "Employee":
	{
		with(oEmpBC)
		{
			ClearToQuery();
			ActivateField("EMail Addr");
			SetViewMode(AllView);
			SetSearchSpec("Id", sToId);
			ExecuteQuery(ForwardOnly);

			if(FirstRecord())
			{
				if(GetFieldValue("EMail Addr") != "")
				{
					sTo = GetFieldValue("EMail Addr");
				}
				else
				{
					Outputs.SetProperty("Result", "ERROR");
					Outputs.SetProperty("Result Info", "Email Not Specified for Employee");
				}
			}
			else
			{
				Outputs.SetProperty("Result", "ERROR");
				Outputs.SetProperty("Result Info", "Position Not Found");
			}
		}
		break;
	}
	//Иначе ничего не делаем
	default:
	{
		Outputs.SetProperty("Result", "ERROR");
		Outputs.SetProperty("Result Info", "Invalid To Type");
	}
}

if(sTo != "")
{
	Outputs.SetProperty("Result", "SUCCESS");
	Outputs.SetProperty("Result Info", "Email Found");
	Outputs.SetProperty("Email", sTo);	
}