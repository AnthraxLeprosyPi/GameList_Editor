unit Main;

interface

uses
   Winapi.Windows, Winapi.Messages,
   System.SysUtils, System.Variants, System.Classes, System.IniFiles, System.Generics.Collections,
   System.DateUtils, System.RegularExpressions,
   Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
   Xml.xmldom, Xml.XMLIntf, Xml.XMLDoc, Vcl.StdCtrls, Xml.Win.msxmldom, Winapi.msxml,
   Vcl.ExtCtrls, Vcl.Imaging.pngimage, Vcl.Imaging.jpeg, Vcl.Menus, Vcl.ComCtrls;

resourcestring
   Rst_NoValidFolder = 'No folder with gamelist.xml found';
   Rst_GamesFound = ' game(s) found.';

type
   TGame = class
   private
      FId: string;
      FRomName: string;
      FName: string;
      FDescription: string;
      FImagePath: string;
      FRating: string;
      FReleaseDate: string;
      FDeveloper: string;
      FPublisher: string;
      FGenre: string;
      FPlayers: string;
      procedure Load( aId, aPath, aName, aDescription, aImagePath, aRating,
                      aDeveloper, aPublisher, aGenre, aPlayers, aDate: string );
   public
      constructor Create( aId, aPath, aName, aDescription, aImagePath, aRating,
                          aDeveloper, aPublisher, aGenre, aPlayers, aDate: string ); reintroduce;
   end;

   TFrm_Editor = class(TForm)
      XMLDoc: TXMLDocument;
      OpenDialog: TFileOpenDialog;
      Cbx_Systems: TComboBox;
      Lbx_Games: TListBox;
      Lbl_NbGamesFound: TLabel;
      Lbl_SelectSystem: TLabel;
      Mmo_Description: TMemo;
      Edt_Rating: TEdit;
      Edt_ReleaseDate: TEdit;
      Edt_Developer: TEdit;
      Edt_Publisher: TEdit;
      Edt_Genre: TEdit;
      Edt_NbPlayers: TEdit;
      Chk_Rating: TCheckBox;
      Chk_ReleaseDate: TCheckBox;
      Chk_Developer: TCheckBox;
      Chk_Publisher: TCheckBox;
      Chk_Genre: TCheckBox;
      Chk_NbPlayers: TCheckBox;
      Chk_Description: TCheckBox;
      Img_Game: TImage;
      Img_BackGround: TImage;
      Edt_Name: TEdit;
      Chk_Name: TCheckBox;
      MainMenu: TMainMenu;
      Mnu_File: TMenuItem;
      Mnu_Choosefolder: TMenuItem;
      Mnu_Quit: TMenuItem;
      Mnu_Actions: TMenuItem;
      Btn_SaveChanges: TButton;
      OpenFile: TOpenDialog;
      Btn_ChangeImage: TButton;
      Btn_SetDefaultPicture: TButton;
      Lbl_Info: TLabel;
      Btn_ChangeAll: TButton;
      Cbx_Filter: TComboBox;
      Lbl_Filter: TLabel;
    Img_Logo: TImage;
      procedure FormCreate(Sender: TObject);
      procedure FormDestroy(Sender: TObject);
      procedure Cbx_SystemsChange(Sender: TObject);
      procedure Lbx_GamesClick(Sender: TObject);
      procedure Mnu_QuitClick(Sender: TObject);
      procedure Mnu_ChoosefolderClick(Sender: TObject);
      procedure ChkClick(Sender: TObject);
      procedure Btn_SaveChangesClick(Sender: TObject);
      procedure FieldChange(Sender: TObject);
      procedure Mmo_DescriptionKeyPress(Sender: TObject; var Key: Char);
      procedure Btn_ChangeImageClick(Sender: TObject);
      procedure Btn_SetDefaultPictureClick(Sender: TObject);
    procedure Cbx_FilterChange(Sender: TObject);
    procedure Btn_ChangeAllClick(Sender: TObject);
   private
      FRootPath: string;
      FRootRomsPath: string;
      FRootImagesPath: string;
      FXmlImagesPath: string;
      FXmlRomsPath: string;
      GSystemList: TObjectDictionary<string,TObjectList<TGame>>;
      procedure BuildSystemsList;
      function BuildGamesList( aPathToFile: string ): TObjectList<TGame>;
      procedure LoadGamesList( aSystem: string );
      procedure LoadGame( aGame: TGame );
      procedure ClearAllFields;
      function FormatDateFromString( aDate: string; aIso: Boolean = False ): string;
      procedure SaveChangesToGamelist;
      procedure EnableControls( aValue: Boolean );
      procedure SetCheckBoxes( aValue: Boolean );
      procedure SetFieldsReadOnly( aValue: Boolean );
      procedure CheckIfChangesToSave;
      procedure ChangeImage( aPath: string; aGame: TGame );
   end;

const
   Cst_Id = 'id';
   Cst_Path = 'path';
   Cst_Game = 'game';
   Cst_Name = 'name';
   Cst_Description = 'desc';
   Cst_ImageLink = 'image';
   Cst_Rating = 'rating';
   Cst_ReleaseDate = 'releasedate';
   Cst_Developer = 'developer';
   Cst_Publisher = 'publisher';
   Cst_Genre = 'genre';
   Cst_Players = 'players';
   Cst_GameListFileName = 'gamelist.xml';
   Cst_DateShortFill = '00';
   Cst_DateLongFill = '0000';
   Cst_DateSuffix = 'T000000';
   Cst_ImageSuffixPng = '-image.png';
   Cst_ImageSuffixJpg = '-image.jpg';
   Cst_ImageSuffixJpeg = '-image.jpeg';
   Cst_DefaultPicsFolderPath = 'Resources\DefaultPictures\';
   Cst_DefaultImageNameSuffix = '-default.png';

var
   Frm_Editor: TFrm_Editor;

implementation

{$R *.dfm}

//Constructeur de l'objet TGame
constructor TGame.Create( aId, aPath, aName, aDescription, aImagePath, aRating,
                          aDeveloper, aPublisher, aGenre, aPlayers, aDate: string );
begin
   Load( aId, aPath, aName, aDescription, aImagePath, aRating,
         aDeveloper, aPublisher, aGenre, aPlayers, aDate );
end;

//Chargement des attributs dans l'objet TGame
procedure TGame.Load( aId, aPath, aName, aDescription, aImagePath, aRating,
                      aDeveloper, aPublisher, aGenre, aPlayers, aDate: string );
begin
   FId:= aId;
   FRomName:= aPath;
   FName:= aName;
   FDescription:= aDescription;
   FImagePath:= aImagePath;
   FRating:= aRating;
   FReleaseDate:= aDate;
   FDeveloper:= aDeveloper;
   FPublisher:= aPublisher;
   FGenre:= aGenre;
   FPlayers:= aPlayers;
end;

//Formate correctement la date depuis la string r�cup�r�e du xml
//ou renvoie une date format Iso pour sauvegarde selon l'appel (aIso)
function TFrm_Editor.FormatDateFromString( aDate: string; aIso: Boolean = False ): string;
var
   FullStr, Day, Month, Year: string;
   DayInt, MonthInt, YearInt: Integer;
begin
   FullStr:= aDate;
   Result:= '';

   //si on formate pour affichage et que la chaine pass�e
   //r�pond au crit�re
   if ( not aIso ) and ( FullStr.Contains( Cst_DateSuffix ) ) then begin
      SetLength( FullStr, 8 );
      Day:= Copy( FullStr, 7, 2 );
      Month:= Copy( FullStr, 5, 2 );
      Year:= Copy( FullStr, 1, 4 );
      if ( TryStrToInt( Day, DayInt ) ) and ( DayInt > 0 ) then
         Result:= Result + Day + '/';
      if ( TryStrToInt( Month, MonthInt ) ) and ( MonthInt > 0 ) then
         Result:= Result + Month + '/';
      if ( TryStrToInt( Year, YearInt ) ) and ( YearInt > 0 ) then
         Result:= Result + Year;

      //sinon si on formate pour enregistrement dans le .xml
      //et que la chaine ne contient que des chiffres ou /
   end else if aIso and ( TRegEx.IsMatch( FullStr, '^[0-9]' ) ) then begin

      //si la chaine fait 4 caract�res de long
      if ( Length( FullStr) = 4 ) then
         Result:= FullStr + Cst_DateLongFill + Cst_DateSuffix;

      //si la chaine fait 7 caract�res de long
      if ( Length( FullStr) = 7 ) then begin
         Month:= Copy( FullStr, 1, 2 );
         Year:= Copy( FullStr, 4, 4 );
         Result:= Year + Month + Cst_DateShortFill + Cst_DateSuffix;
      end;

      //si la chaine fait 10 caract�res de long
      if ( Length( FullStr) = 10 ) then begin
         Day:= Copy( FullStr, 1, 2 );
         Month:= Copy( FullStr, 4, 2 );
         Year:= Copy( FullStr, 7, 4 );
         Result:= Year + Month + Day + Cst_DateSuffix;
      end;
   end;
end;

//A l'ouverture du programme
procedure TFrm_Editor.FormCreate(Sender: TObject);
begin
   Lbl_NbGamesFound.Caption:= '';
   GSystemList:= TObjectDictionary<string, TObjectList<TGame>>.Create([doOwnsValues]);
end;

//Action au click sur le menuitem "choose folder"
procedure TFrm_Editor.Mnu_ChoosefolderClick(Sender: TObject);
begin
   EnableControls( False );
   ClearAllFields;
   Lbx_Games.Items.Clear;
   BuildSystemsList;
   SetCheckBoxes( False );
   Btn_SaveChanges.Enabled:= False;
end;

//Construction de la liste des syst�mes trouv�s (et des listes de jeux associ�es)
procedure TFrm_Editor.BuildSystemsList;
var
   _GameListPath: string;
   Info: TSearchRec;
   IsFound: Boolean;
   ValidFolderCount: Integer;
   TmpList: TObjectList<TGame>;
begin
   //on met � vide tous les chemins
   FRootPath:= '';
   FRootRomsPath:= '';
   FRootImagesPath:= '';

   //On vide le combobox des syst�mes
   //Et on d�sactive les Controls non n�cessaires
   Cbx_Systems.Items.Clear;
   Cbx_Systems.Enabled:= False;
   Cbx_Filter.Enabled:= False;
   Lbx_Games.Enabled:= False;
   Lbl_SelectSystem.Enabled:= False;
   Lbl_Filter.Enabled:= False;
   Lbl_NbGamesFound.Caption:= '';
   Btn_ChangeAll.Enabled:= False;

    //On vide la liste globale des syst�mes (cas 2eme ouverture)
    GSystemList.Clear;

   //On met le compteur de dossiers valides � 0
   ValidFolderCount:= 0;

   //On s�lectionne le dossier parent o� se trouvent les dossiers de syst�mes
   if ( OpenDialog.Execute ) then begin
      //On r�cup�re le chemin vers le dossier parent
      FRootPath:= IncludeTrailingPathDelimiter( OpenDialog.FileName );

      //On check si le dossier n'est pas vide
      IsFound:= ( FindFirst( FRootPath + '*.*', faAnyFile, Info) = 0 );

      //Si le dossier est vide : message utilisateur
      if not IsFound then
         ShowMessage( Rst_NoValidFolder );

      //On boucle sur les dossiers trouv�s pour les lister
      while IsFound do begin

         //Si le dossier trouv� ne commence pas par un . et qu'il contient
         //bien un fichier gamelist.xml alors on cr�e la liste de jeux
         if ( (Info.Attr and faDirectory) <> 0 ) and
            ( Info.Name[1] <> '.' ) and
            ( FileExists( FRootPath + Info.Name + '\' + Cst_GameListFileName ) ) then begin

            //Ici on r�cup�re le chemin vers le fichier gamelist.xml
            _GameListPath:= FRootPath + Info.Name + '\' + Cst_GameListFileName;

            //On tente de construire la liste des jeux depuis le .xml
            TmpList:= BuildGamesList( _GameListPath );

            //Si la liste n'est pas vide, on traite, sinon on zappe
            if Assigned( TmpList ) then begin

               //On construit la liste des jeux du syst�me
               //et on joute le syst�me � la liste globale de syst�mes
               GSystemList.Add( Info.Name, TmpList );

               //On ajoute ensuite le nom du systeme au combobox des systemes trouv�s
               Cbx_Systems.Items.Add( Info.Name );

               //On incr�mente le compteur de dossier syst�me valides
               Inc( ValidFolderCount );
            end;
         end;

         //Enfin, on passe au dossier suivant (s'il y en a un)
         IsFound:= ( FindNext(Info) = 0 );
      end;
      FindClose(Info);

      //Si le compteur de dossier valide est � z�ro, message utilisateur
      if ( ValidFolderCount = 0 ) then begin
         ShowMessage( Rst_NoValidFolder );
         Exit;
      end;

      //On active le Combobox des systemes si au moins un systeme a �t� trouv�
      //Idem pour le listbox des jeux du systeme et on charge la liste du premier syst�me
      if not ( ValidFolderCount = 0 ) then begin
         Cbx_Systems.Enabled:= True;
         Lbx_Games.Enabled:= Cbx_Systems.Enabled;
         Lbl_SelectSystem.Enabled:= Cbx_Systems.Enabled;
         Cbx_Filter.Enabled:= Cbx_Systems.Enabled;
         Lbl_Filter.Enabled:= Cbx_Systems.Enabled;
         Cbx_Systems.ItemIndex:= 0;
         LoadGamesList( Cbx_Systems.Items[0] );
         EnableControls( True );
      end;

      //On remet le curseur par d�faut
      Cursor:= crDefault;
   end;
end;

//Construction de la liste des jeux (objets) pour un systeme donn�
function TFrm_Editor.BuildGamesList( aPathToFile: string ): TObjectList<TGame>;

   //Permet de s'assurer que le noeud cherch� existe, et si ce n'est pas le cas
   //renvoie chaine vide, sinon renvoie la valeur texte du noeud
   function GetNodeValue( aNode: IXMLNode; aNodeName: string ): string;
   begin
      Result:= '';
      if Assigned( aNode.ChildNodes.FindNode( aNodeName ) ) then
         Result:= aNode.ChildNodes.Nodes[aNodeName].Text;
   end;

var
   _GameList: TObjectList<TGame>;
   _Game: TGame;
   _Node: IXmlNode;
begin
   //on met le curseur sablier pour montrer que �a bosse.
   Cursor:= crHourGlass;

   //Initialisation � nil au cas o� liste de jeux vide
   Result:= nil;

   //On ouvre et active le gamelist.xml pour le parcourir
   XMLDoc.FileName:= aPathToFile;
   XMLDoc.Active:= True;

   //On cherche le premier "jeu"
   _Node := XMLDoc.DocumentElement.ChildNodes.FindNode( Cst_Game );

   //Si pas de jeu trouv� on sort et on renvoie nil
   if not Assigned( _Node ) then Exit;

    //On cr�e la liste d'objets TGame
    _GameList:= TObjectList<TGame>.Create( True );

   //Ensuite on boucle sur tous les jeux et pour chaque jeu
   //on cr�e un objet TGame qu'on renseigne et ajoute � la _Gamelist
   repeat
      //On ne cr�e un "jeu" que si le noeud n'est pas vide.
      if _Node.HasChildNodes then begin

         //Cr�ation de l'objet TGame et passage des infos en argument
         _Game:= TGame.Create( _Node.AttributeNodes[Cst_Id].Text,
                               GetNodeValue( _Node, Cst_Path ),
                               GetNodeValue( _Node, Cst_Name ),
                               GetNodeValue( _Node,Cst_Description ),
                               GetNodeValue( _Node, Cst_ImageLink ),
                               GetNodeValue( _Node, Cst_Rating ),
                               GetNodeValue( _Node, Cst_Developer ),
                               GetNodeValue( _Node, Cst_Publisher ),
                               GetNodeValue( _Node, Cst_Genre ),
                               GetNodeValue( _Node, Cst_Players ),
                               FormatDateFromString( GetNodeValue( _Node, Cst_ReleaseDate ) ) );

         //On ajoute � la _Gamelist
         _GameList.Add( _Game );
      end;

      //On passe au jeu suivant
      _Node := _Node.NextSibling;
   until ( _Node = nil );

   XMLDoc.Active:= False;

   Result:= _GameList;
end;

//Action � la s�lection d'un filtre
procedure TFrm_Editor.Cbx_FilterChange(Sender: TObject);
begin
   LoadGamesList( Cbx_Systems.Items[Cbx_Systems.ItemIndex] );
end;

//Action � la s�lection d'un item du combobox systemes
procedure TFrm_Editor.Cbx_SystemsChange(Sender: TObject);
begin
   LoadGamesList( Cbx_Systems.Items[Cbx_Systems.ItemIndex] );
end;

//Je fais une proc�dure juste pour activer les controls
//pour pas se les retaper � chaque changement d'�tat
procedure TFrm_Editor.EnableControls( aValue: Boolean );
begin
   Chk_Name.Enabled:= aValue;
   Chk_Genre.Enabled:= aValue;
   Chk_Rating.Enabled:= aValue;
   Chk_Developer.Enabled:= aValue;
   Chk_Publisher.Enabled:= aValue;
   Chk_NbPlayers.Enabled:= aValue;
   Chk_ReleaseDate.Enabled:= aValue;
   Chk_Description.Enabled:= aValue;
   Btn_ChangeImage.Enabled:= aValue;
   Btn_SetDefaultPicture.Enabled:= aValue;
   Lbl_Info.Enabled:= aValue;
end;

//Permet de tout cocher ou d�cocher les checkboxes d'un coup
procedure TFrm_Editor.SetCheckBoxes( aValue: Boolean );
begin
   Chk_Name.Checked:= aValue;
   Chk_Genre.Checked:= aValue;
   Chk_Rating.Checked:= aValue;
   Chk_Developer.Checked:= aValue;
   Chk_Publisher.Checked:= aValue;
   Chk_NbPlayers.Checked:= aValue;
   Chk_ReleaseDate.Checked:= aValue;
   Chk_Description.Checked:= aValue;
end;

//Repasse tous les champs en readonly ou non
procedure TFrm_Editor.SetFieldsReadOnly( aValue: Boolean );
begin
   Edt_Name.ReadOnly:= aValue;
   Edt_Genre.ReadOnly:= aValue;
   Edt_Rating.ReadOnly:= aValue;
   Edt_Developer.ReadOnly:= aValue;
   Edt_Publisher.ReadOnly:= aValue;
   Edt_NbPlayers.ReadOnly:= aValue;
   Edt_ReleaseDate.ReadOnly:= aValue;
   Mmo_Description.ReadOnly:= aValue;
end;

//Action lorsqu'on change le contenu d'un des champs
procedure TFrm_Editor.FieldChange(Sender: TObject);
begin
   CheckIfChangesToSave;
end;

//On v�rifie si il y a des changements pour activer le bouton
// "Save changes" ou non
procedure TFrm_Editor.CheckIfChangesToSave;
var
   _Game: TGame;
begin
   _Game:= ( Lbx_Games.Items.Objects[Lbx_Games.ItemIndex] as TGame );
   Btn_SaveChanges.Enabled:= not ( _Game.FName.Equals( Edt_Name.Text ) ) or
                             not ( _Game.FGenre.Equals( Edt_Genre.Text ) ) or
                             not ( _Game.FRating.Equals( Edt_Rating.Text ) ) or
                             not ( _Game.FPlayers.Equals( Edt_NbPlayers.Text ) ) or
                             not ( _Game.FDeveloper.Equals( Edt_Developer.Text ) ) or
                             not ( _Game.FPublisher.Equals( Edt_Publisher.Text ) ) or
                             not ( _Game.FReleaseDate.Equals( Edt_ReleaseDate.Text ) ) or
                             not ( _Game.FDescription.Equals( Mmo_Description.Text ) );
end;

//Chargement de la liste des jeux d'un syst�me dans le listbox des jeux
procedure TFrm_Editor.LoadGamesList( aSystem: string );
var
   _PathFound: Boolean;

   //permet de r�cup�rer le chemin vers les images (du xml)
   //et roms pour le syst�me s�lectionn�
   procedure GetPaths( aGame: TGame );
   var
      Pos: Integer;
      tmpStr: string;
   begin
      Pos:= LastDelimiter( '/', aGame.FImagePath );
      FXmlImagesPath:= Copy( aGame.FImagePath, 1, Pos );
      Pos:= LastDelimiter( '/', aGame.FRomName );
      FXmlRomsPath:= Copy( aGame.FImagePath, 1, Pos );
      FRootRomsPath:= IncludeTrailingPathDelimiter( FRootPath +
                                                    Cbx_Systems.Items[Cbx_Systems.ItemIndex] );
      tmpStr:= Copy( FXmlImagesPath, 1, Pred( FXmlImagesPath.Length ) );
      Pos:= LastDelimiter( '/', tmpStr );
      tmpStr:= Copy( FXmlImagesPath, Succ( Pos ), ( FXmlImagesPath.Length - Succ( Pos ) ) );
      FRootImagesPath:= IncludeTrailingPathDelimiter( FRootRomsPath + tmpStr );
   end;

   //Permet de v�rifier si l'image existe "physiquement"
   //car il se peut que le lien soit renseign� mais que l'image
   //n'existe pas dans le dossier des images...
   function CheckIfImageMissing( aLink: string ): Boolean;
   var
      Pos: Integer;
      _ImagePath: string;
   begin
      Result:= True;
      Pos:= LastDelimiter( '/', aLink );
      _ImagePath:= FRootImagesPath + Copy( aLink, Succ( Pos ), ( aLink.Length - Pos ) );
      if FileExists( _ImagePath ) then Result:= False;
   end;

var
   _TmpList: TObjectList<TGame>;
   _TmpGame: TGame;
   _FilterIndex: Integer;
begin
   //on stocke le "numero" de filtre.
   _FilterIndex:= Cbx_Filter.ItemIndex;
   _PathFound:= False;

   //On essaye de r�cup�rer la liste de jeux du syst�me choisi
   if GSystemList.TryGetValue( aSystem, _TmpList ) then begin

      //On d�sactive les �v�nements sur les changements dans les champs
      //Sinon �a p�te quand on change de syst�me (indice hors limite)
      Edt_Name.OnChange:= nil;
      Edt_Rating.OnChange:= nil;
      Edt_ReleaseDate.OnChange:= nil;
      Edt_Genre.OnChange:= nil;
      Edt_Developer.OnChange:= nil;
      Edt_Publisher.OnChange:= nil;
      Edt_NbPlayers.OnChange:= nil;
      Mmo_Description.OnChange:= nil;

      //On commence par vider le listbox
      Lbx_Games.Items.Clear;

      //On boucle sur la liste de jeux pour ajouter les noms
      //dans le listbox de la liste des jeux
      for _TmpGame in _TmpList do begin

         //R�cup du lien vers les images pour ce syst�me (lien xml)
         if not ( _TmpGame.FImagePath.IsEmpty ) and
            not _PathFound then begin
            GetPaths( _TmpGame );
            _PathFound:= True;
         end;

         //Attention usine � gaz bool�enne pour g�rer les filtres ^^
         if ( _FilterIndex = 0 ) or
            ( ( _FilterIndex = 1 ) and ( CheckIfImageMissing( _TmpGame.FImagePath ) ) ) or
            ( ( _FilterIndex = 2 ) and ( _TmpGame.FReleaseDate.IsEmpty ) ) or
            ( ( _FilterIndex = 3 ) and ( _TmpGame.FPlayers.IsEmpty ) ) or
            ( ( _FilterIndex = 4 ) and ( _TmpGame.FRating.IsEmpty ) ) or
            ( ( _FilterIndex = 5 ) and ( _TmpGame.FDeveloper.IsEmpty ) ) or
            ( ( _FilterIndex = 6 ) and ( _TmpGame.FPublisher.IsEmpty ) ) or
            ( ( _FilterIndex = 7 ) and ( _TmpGame.FDescription.IsEmpty ) ) or
            ( ( _FilterIndex = 8 ) and ( _TmpGame.FGenre.IsEmpty ) ) then begin

            Lbx_Games.Items.AddObject( _TmpGame.FName, _TmpGame );
         end
      end;

      //On indique le nombre de jeux trouv�s
      Lbl_NbGamesFound.Caption:= aSystem + ' : ' + IntToStr( Lbx_Games.Items.Count ) + Rst_GamesFound;

      //On met le focus sur le premier jeu de la liste
      ClearAllFields;
      Lbx_Games.SetFocus;

      //Si il y a des jeux dans la liste on affiche auto le premier
      if ( Lbx_Games.Items.Count > 0 ) then begin
         Lbx_Games.Selected[0]:= True;
         LoadGame( ( Lbx_Games.Items.Objects[0] as TGame ) );
         Btn_ChangeAll.Enabled:= ( Cbx_Filter.ItemIndex = 1 );
         EnableControls( True );
      end else begin
         Btn_ChangeAll.Enabled:= False;
         EnableControls( False );
      end;

      //on remet les �v�nements sur les champs
      Edt_Name.OnChange:= FieldChange;
      Edt_Rating.OnChange:= FieldChange;
      Edt_ReleaseDate.OnChange:= FieldChange;
      Edt_Genre.OnChange:= FieldChange;
      Edt_Developer.OnChange:= FieldChange;
      Edt_Publisher.OnChange:= FieldChange;
      Edt_NbPlayers.OnChange:= FieldChange;
      Mmo_Description.OnChange:= FieldChange;
   end;
end;

//Click sur un jeu dans la liste
procedure TFrm_Editor.Lbx_GamesClick(Sender: TObject);
begin
   ClearAllFields;
   SetCheckBoxes( False );
   LoadGame( ( Lbx_Games.Items.Objects[Lbx_Games.ItemIndex] as TGame ) )
end;

//Chargement dans les diff�rents champs des infos du jeu s�lectionn�
procedure TFrm_Editor.LoadGame( aGame: TGame );
var
   _Image: TPngImage;
   _ImageJpg: TJPEGImage;
   _RawGameName, _PathToImage: string;
begin
   Edt_Name.Text:= aGame.FName;
   Edt_Rating.Text:= aGame.FRating;
   Edt_ReleaseDate.Text:= aGame.FReleaseDate;
   Edt_Publisher.Text:= aGame.FPublisher;
   Edt_Developer.Text:= aGame.FDeveloper;
   Edt_NbPlayers.Text:= aGame.FPlayers;
   Edt_Genre.Text:= aGame.FGenre;
   Mmo_Description.Text:= aGame.FDescription;

   //on r�cup�re le nom brut du jeu pour construire le chemin vers l'image
   _RawGameName:= Copy( aGame.FRomName, 3, ( aGame.FRomName.Length - 2 ) );
   SetLength( _RawGameName, LastDelimiter( '.', _RawGameName ) - 1 );
   _PathToImage:= FRootImagesPath + _RawGameName;

   //si l'image existe (et chemin existe dans xml)
   //on la charge pour affichage (d�tection du format) sinon on laisse l'image par d�faut
   if FileExists( _PathToImage + Cst_ImageSuffixPng ) and
      not ( aGame.FImagePath.IsEmpty ) then begin
      _Image:= TPngImage.Create;
      try
         _Image.LoadFromFile( _PathToImage + Cst_ImageSuffixPng );
         Img_Game.Picture.Graphic:= _Image;
         Exit;
      finally
         _Image.Free;
      end;
   end else if FileExists( _PathToImage + Cst_ImageSuffixJpg ) and
               not ( aGame.FImagePath.IsEmpty ) then begin
      _ImageJpg:= TJPEGImage.Create;
      try
         _ImageJpg.LoadFromFile( _PathToImage + Cst_ImageSuffixJpg );
         Img_Game.Picture.Graphic:= _ImageJpg;
         Exit;
      finally
         _ImageJpg.Free;
      end;
   end else if FileExists( _PathToImage + Cst_ImageSuffixJpeg ) and
               not ( aGame.FImagePath.IsEmpty ) then begin
      _ImageJpg:= TJPEGImage.Create;
      try
         _ImageJpg.LoadFromFile( _PathToImage + Cst_ImageSuffixJpeg );
         Img_Game.Picture.Graphic:= _ImageJpg;
         Exit;
      finally
         _ImageJpg.Free;
      end;
   end;
end;

//Action au click sur bouton "change image"
//Ouvre une boite de dialogue pour changer l'image du jeu s�lectionn�
procedure TFrm_Editor.Btn_ChangeImageClick(Sender: TObject);
var
   _Game: TGame;
begin
   if OpenFile.Execute and ( OpenFile.FileName <> '' ) then begin
      _Game:= ( Lbx_Games.Items.Objects[Lbx_Games.ItemIndex] as TGame );
      ChangeImage( OpenFile.FileName, _Game );
      LoadGamesList( Cbx_Systems.Items[Cbx_Systems.ItemIndex] );
   end;
end;

//Action au click sur bouton "change picture to default"
//Change l'image actuelle du jeu s�lectionn� pour celle par d�faut
procedure TFrm_Editor.Btn_SetDefaultPictureClick(Sender: TObject);
var
   PathToDefault: string;
   _Game: TGame;
begin
   _Game:= ( Lbx_Games.Items.Objects[Lbx_Games.ItemIndex] as TGame );

   //On construit le lien vers l'image d�faut selon le syst�me
   PathToDefault:= ExtractFilePath(Application.ExeName) +
                   Cst_DefaultPicsFolderPath + '\' +
                   Cbx_Systems.Items[Cbx_Systems.ItemIndex] +
                   Cst_DefaultImageNameSuffix;

   ChangeImage( PathToDefault, _Game );

   //on update la liste pour refl�ter les changements
   LoadGamesList( Cbx_Systems.Items[Cbx_Systems.ItemIndex] );
end;

//Action au click "change all missing to default"
//Assigne l'image defaut du syst�me � tous les jeux qui n'ont pas d'image
procedure TFrm_Editor.Btn_ChangeAllClick(Sender: TObject);
var
   ii: Integer;
   PathToDefault: string;
   _Game: TGame;
begin
   //On construit le lien vers l'image d�faut selon le syst�me
   PathToDefault:= ExtractFilePath(Application.ExeName) +
                   Cst_DefaultPicsFolderPath + '\' +
                   Cbx_Systems.Items[Cbx_Systems.ItemIndex] +
                   Cst_DefaultImageNameSuffix;

   //et on boucle sur tous les jeux de la liste pour remplacer l'image
   for ii:= 0 to Pred( Lbx_Games.Items.Count ) do begin
      _Game:= ( Lbx_Games.Items.Objects[ii] as TGame );
      ChangeImage( PathToDefault, _Game );
   end;

   //on update la liste pour refl�ter les changements
   LoadGamesList( Cbx_Systems.Items[Cbx_Systems.ItemIndex] );
end;

//Remplace l'image actuelle du jeu (par autre ou d�faut).
procedure TFrm_Editor.ChangeImage( aPath: string; aGame: TGame );
var
   _Image: TPngImage;
   _ImageJpg: TJPEGImage;
   _GameName, _ImageLink: string;
   _Node: IXMLNode;

begin
   Cursor:= crHourGlass;

   //on r�cup�re le nom du jeu pour construire le nom de l'image
   _GameName:= Copy( aGame.FRomName, 3, ( aGame.FRomName.Length - 2 ) );
   SetLength( _GameName, LastDelimiter( '.', _GameName ) - 1 );

   //on d�termine ensuite l'extension du fichier charg� et
   //on cr�e l'objet qui va bien pour affecter au TImage
   if ( ExtractFileExt( aPath ) = '.png' ) then begin
      _Image:= TPngImage.Create;
      try
         _Image.LoadFromFile( aPath );
         Img_Game.Picture.Graphic:= _Image;
      finally
         _Image.Free;
      end;
   end else begin
      _ImageJpg:= TJPEGImage.Create;
      try
         _ImageJpg.LoadFromFile( aPath );
         Img_Game.Picture.Graphic:= _ImageJpg;
      finally
         _ImageJpg.Free;
      end;
   end;

   //on sauvegarde l'image dans le dossier avec les autres !!
   // et on ajoute le chemin dans le xml
   Img_Game.Picture.SaveToFile( FRootImagesPath + _GameName + Cst_ImageSuffixPng );

   //On ouvre le fichier xml
   XMLDoc.LoadFromFile( FRootRomsPath + Cst_GameListFileName );
   XMLDoc.Active:= True;

   //On r�cup�re le premier noeud "game"
   _Node := XMLDoc.DocumentElement.ChildNodes.FindNode( Cst_Game );

   //Et on boucle pour trouver le noeud avec le bon Id
   repeat
      if ( _Node.AttributeNodes[Cst_Id].Text = aGame.FId ) then Break;
      _Node := _Node.NextSibling;
   until not Assigned( _Node );

   //on �crit le chemin vers l'image
   _ImageLink:= FXmlImagesPath + _GameName + Cst_ImageSuffixPng;
   _Node.ChildNodes.Nodes[Cst_ImageLink].Text:= _ImageLink;

   //On enregistre le fichier.
   XMLDoc.SaveToFile( FRootRomsPath + Cst_GameListFileName );
   XMLDoc.Active:= False;

   //Et enfin on met � jour l'objet TGame associ�
   aGame.FImagePath:= _ImageLink;

   Cursor:= crDefault;
end;

//Action au click sur bouton "save changes"
procedure TFrm_Editor.Btn_SaveChangesClick(Sender: TObject);
begin
   SaveChangesToGamelist;
   LoadGamesList( Cbx_Systems.Items[Cbx_Systems.ItemIndex] );
   SetCheckBoxes( False );
   SetFieldsReadOnly( True );
   Btn_SaveChanges.Enabled:= False;
end;

//Enregistre les changements effectu�s pour le jeu dans le fichier .xml
//et rafraichit le listbox si besoin
procedure TFrm_Editor.SaveChangesToGamelist;
var
   _Node: IXMLNode;
   _Game: TGame;
   _GameListPath, _Date: string;
begin
   //On r�cup�re le chemin du fichier gamelist.xml
   _GameListPath:= FRootRomsPath + Cst_GameListFileName;

   //On r�cup�re l'objet TGame qu'on souhaite modifier
   _Game:= ( Lbx_Games.Items.Objects[Lbx_Games.ItemIndex] as TGame );

   //On ouvre le fichier xml
   XMLDoc.LoadFromFile( _GameListPath );
   XMLDoc.Active:= True;

   //On r�cup�re le premier noeud "game"
   _Node := XMLDoc.DocumentElement.ChildNodes.FindNode( Cst_Game );

   //Et on boucle pour trouver le noeud avec le bon Id
   repeat
      if ( _Node.AttributeNodes[Cst_Id].Text = _Game.FId ) then Break;
      _Node := _Node.NextSibling;
   until not Assigned( _Node );

   //On peut maintenant mettre les infos � jour dans le xml si besoin
   if not ( _Game.FName.Equals( Edt_Name.Text ) ) then begin
      _Node.ChildNodes.Nodes[Cst_Name].Text:= Edt_Name.Text;
      _Game.FName:= Edt_Name.Text;
      Lbx_Games.Items[Lbx_Games.ItemIndex]:= Edt_Name.Text;
   end;
   if not ( _Game.FGenre.Equals( Edt_Genre.Text ) ) then begin
      _Node.ChildNodes.Nodes[Cst_Genre].Text:= Edt_Genre.Text;
      _Game.FGenre:= Edt_Genre.Text;
   end;
   if not ( _Game.FRating.Equals( Edt_Rating.Text ) ) then begin
      _Node.ChildNodes.Nodes[Cst_Rating].Text:= Edt_Rating.Text;
      _Game.FRating:= Edt_Rating.Text;
   end;
   if not ( _Game.FPlayers.Equals( Edt_NbPlayers.Text ) ) then begin
      _Node.ChildNodes.Nodes[Cst_Players].Text:= Edt_NbPlayers.Text;
      _Game.FPlayers:= Edt_NbPlayers.Text;
   end;
   if not ( _Game.FDeveloper.Equals( Edt_Developer.Text ) ) then begin
      _Node.ChildNodes.Nodes[Cst_Developer].Text:= Edt_Developer.Text;
      _Game.FDeveloper:= Edt_Developer.Text;
   end;
   if not ( _Game.FReleaseDate.Equals( Edt_ReleaseDate.Text ) ) then begin
      _Date:= FormatDateFromString( Edt_ReleaseDate.Text, True );
      if not _Date.IsEmpty then
         _Game.FReleaseDate:= Edt_ReleaseDate.Text
      else begin
         _Game.FReleaseDate:= '';
         Edt_ReleaseDate.Text:= '';
      end;
      _Node.ChildNodes.Nodes[Cst_ReleaseDate].Text:= _Date;
   end;
   if not ( _Game.FPublisher.Equals( Edt_Publisher.Text ) ) then begin
      _Node.ChildNodes.Nodes[Cst_Publisher].Text:= Edt_Publisher.Text;
      _Game.FPublisher:= Edt_Publisher.Text;
   end;
   if not ( _Game.FDescription.Equals( Mmo_Description.Text ) ) then begin
      _Node.ChildNodes.Nodes[Cst_Description].Text:= Mmo_Description.Text;
      _Game.FDescription:= Mmo_Description.Text;
   end;

   //Et enfin on enregistre le fichier.
   XMLDoc.SaveToFile( _GameListPath );
   XMLDoc.Active:= False;
end;

//Vidage de tous les champs et de l'image
procedure TFrm_Editor.ClearAllFields;
begin
   Edt_Name.Text:= '';
   Edt_Rating.Text:= '';
   Edt_ReleaseDate.Text:= '';
   Edt_Publisher.Text:= '';
   Edt_Developer.Text:= '';
   Edt_NbPlayers.Text:= '';
   Edt_Genre.Text:= '';
   Mmo_Description.Text:= '';
   Img_Game.Picture.Graphic:= nil;
end;

//Centralisation de l'�v�nement click sur checkbox
//(passage du champ correspondant en read/write)
procedure TFrm_Editor.ChkClick(Sender: TObject);
begin
   //Si la liste de jeux est vide, on sort
   if Lbx_Games.Items.Count = 0 then Exit;

   //On active le champ correspondant au checkbox coch� ou non
   case (Sender as TCheckBox).Tag of
      1: Edt_Name.ReadOnly:= not (Sender as TCheckBox).Checked;
      2: Edt_ReleaseDate.ReadOnly:= not (Sender as TCheckBox).Checked;
      3: Edt_NbPlayers.ReadOnly:= not (Sender as TCheckBox).Checked;
      4: Edt_Rating.ReadOnly:= not (Sender as TCheckBox).Checked;
      5: Edt_Publisher.ReadOnly:= not (Sender as TCheckBox).Checked;
      6: Edt_Developer.ReadOnly:= not (Sender as TCheckBox).Checked;
      7: Edt_Genre.ReadOnly:= not (Sender as TCheckBox).Checked;
      8: Mmo_Description.ReadOnly:= not (Sender as TCheckBox).Checked;
   end;
end;

//Sans �a pas de Ctrl+A dans le m�mo...(c'est triste en 2017)
procedure TFrm_Editor.Mmo_DescriptionKeyPress(Sender: TObject; var Key: Char);
begin
   if ( Key = ^A ) then begin
      (Sender as TMemo).SelectAll;
       Key:= #0;
   end;
end;

//Click sur le menuitem "Quit"
procedure TFrm_Editor.Mnu_QuitClick(Sender: TObject);
begin
   Application.Terminate;
end;

 //Nettoyage m�moire � la fermeture du programme
procedure TFrm_Editor.FormDestroy(Sender: TObject);
begin
   //Toutes les listes �tant "owner" de leurs objets
   //un simple Free sur cette liste videra automatiquement les autres
   GSystemList.Free;
end;

end.
