<%@ Page Title="KPIs Page" Async="true" Language="C#" MasterPageFile="~/Site.Master" EnableEventValidation="false" AutoEventWireup="true" CodeBehind="RegistrationKPIs.aspx.cs" Inherits="SmartHotel.Registration.RegistrationKPIs" %>

<%@ register assembly="System.Web.DataVisualization, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" namespace="System.Web.UI.DataVisualization.Charting" tagprefix="asp" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <section class="sh-form">
        <h2 class="sh-title">Reservation KPIs</h2>
        <div class="sh-form_wrapper">
            <div class="row">
                <section class="col-sm-3 customer-information">
                    <asp:DropDownList ID="CustomerList" runat="server" AutoPostBack="True" OnSelectedIndexChanged="Selection_Change">
                        <asp:ListItem Selected="True" Value="All">All Customer</asp:ListItem>
                    </asp:DropDownList>
                </section>
                <section class="col-sm-9 customer-information">
                    <asp:Chart ID="Chart" runat=server Height="300px" Width="400px">
        <Titles>  
        <asp:Title ShadowOffset="3" Name="Number of Checkin per Season" />  
    </Titles> 
        <Legends>  
        <asp:Legend Alignment="Center" Docking="Bottom" IsTextAutoFit="False" Name="Default" LegendStyle="Row" />  
    </Legends>  
        <Series>
            <asp:Series Name="NumberOfCheckin">
                
            </asp:Series>
        </Series>
        <ChartAreas>
            <asp:ChartArea Name="ChartArea1">

            </asp:ChartArea>

        </ChartAreas>

    </asp:Chart>
                </section>
            </div>
            <div class="row">
                <section class="col-sm-6">      
                    <div class="form-group">                       
                        <asp:Button ID="Button2" class="btn btn-secondary" runat="server" OnClick="CancelBtn_Click"  Text="Back" />
                    </div>
                </section>
            </div>
        </div>
    </section>
    
    
    
</asp:Content>
