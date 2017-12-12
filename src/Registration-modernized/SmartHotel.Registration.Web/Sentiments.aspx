<%@ Page Title="Sentiments" Async="true" Language="C#" MasterPageFile="~/Site.Master" EnableEventValidation="false" AutoEventWireup="true" CodeBehind="Sentiments.aspx.cs" Inherits="SmartHotel.Registration._Sentiments" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <asp:GridView ID="RegistrationGrid" runat="server"
            AutoGenerateColumns="false"
            OnRowDataBound="SentimentGrid_RowDataBound">
            <Columns>
                <asp:BoundField DataField="Id" Visible="false" />
                <asp:BoundField DataField="Sentiment" HeaderText="Sentiment" DataFormatString="{0:P}" />
                <asp:BoundField DataField="Hashtags" HeaderText="Hashtags" />
                <asp:BoundField DataField="UserName" HeaderText="User" />
                <asp:BoundField DataField="Text" HeaderText="Text" />
                <%--<asp:HyperLinkField Text="Link" DataNavigateUrlFields="TweetUrl" HeaderText="URL" />--%>
                <%--<asp:ImageField DataImageUrlField="UserPictureUrl" HeaderText="User Picture" />--%>
                
            </Columns>
        </asp:GridView>
    </div>
</asp:Content>
